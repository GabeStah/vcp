class Raid < ActiveRecord::Base
  belongs_to :zone
  has_many :participations, dependent: :delete_all
  # Destroy participations associated with Raid
  has_many :characters, -> { uniq }, through: :participations, dependent: :delete_all
  has_many :standing_events

  before_update :destroy_standing_events
  before_update :reset_processed
  after_update :process_standing_events
  after_destroy :destroy_standing_events

  # ended_at
  validate :ended_at_is_valid_datetime
  validates :ended_at,
            allow_blank: true,
            uniqueness: true
  validates :processed,
            inclusion: [true, false]
  # started_at
  validates :started_at,
            presence: true,
            uniqueness: true
  validate :started_at_is_valid_datetime
  # Dates should be logical
  validate :dates_are_consecutive

  def add_participations_from_params(params)
    # Add participation records
    if params
      # Loop timestamps
      params['timestamp'].each do |id, data|
        data.each do |count, timestamp|
          in_raid = false
          online = false
          unexcused_absence = false
          # Check online
          unless params['online'].nil? || params['online'][id].nil?
            online = true if params['online'][id][count] && params['online'][id][count] == '1'
          end
          # Check in_raid
          unless params['in_raid'].nil? || params['in_raid'][id].nil?
            in_raid = true if params['in_raid'][id][count] && params['in_raid'][id][count] == '1'
          end
          # Check in_raid
          unless params['unexcused'].nil? || params['unexcused'][id].nil?
            unexcused_absence = true if params['unexcused'][id][count] && params['unexcused'][id][count] == '1'
          end
          self.participations.create(character: Character.find(id), in_raid: in_raid, online: online, timestamp: timestamp)
          # Unexcused Absence
          if unexcused_absence && !online && !in_raid
            StandingEvent.create!(change: Settings.standing.unexcused_absence_loss,
                                  raid: self,
                                  standing: Standing.where(character: Character.find(id)).first,
                                  type: :infraction)
          end
        end
      end
      # Calculate standing_events
      process_standing_events
    end
  end

  def attendees
    all_attendees = Array.new
    # Primary stage firstself.participations
    characters.each do |character|
      # Find character participation set
      participations = self.participations.where(character: character).order(:timestamp)
      # Create StandingCalculation instance WITHOUT processing
      standing_calculation = StandingCalculation.new(character: character, participations: participations, raid: self, skip_process: true)
      in_raid = standing_calculation.first_time(event: :in_raid, during_raid: true, within_cutoff: true)
      online = standing_calculation.first_time(event: :online, during_raid: true, within_cutoff: true)
      # Verify that character qualified for attendence_loss
      if in_raid.present? && online.present? && standing_calculation.qualified_for_attendance?
        all_attendees << character unless all_attendees.include? character
      end
    end
    all_attendees
  end

  # All raids between date range
  def self.between(before: Time.zone.now, after: Time.zone.local(1970))
    where("#{table_name}.started_at <= ?", before).where("#{table_name}.started_at >= ?", after)
  end

  def ended_at=(t)
    t = TimeManagement.local(t)
    super(t)
  end

  def full_title
    "#{zone.name} @ #{I18n.l(started_at.in_time_zone)}"
  end

  def process_standing_events
    unless processed
      # Set attendance_loss
      update_attendance_loss
      # Primary stage firstself.participations
      self.characters.each do |character|
        # Find character participation set
        participations = self.participations.where(character: character).order(:timestamp)
        # Create StandingCalculation instance
        standing_calculation = StandingCalculation.new(character: character, participations: participations, raid: self)
      end
      # After processing, set processed flag
      update_column(:processed, true)
    end
  end

  # Used to fully reset standing_events associated with raid
  # Called when Participation is changed
  def reset_standing_events
    destroy_standing_events
    # Reset processed flag
    reset_processed
    process_standing_events
  end

  def self.skip_time_zone_conversion_for_attributes
    [:ended_at, :started_at]
  end

  def started_at=(t)
    t = TimeManagement.local(t)
    super(t)
  end

  def update_attendance_loss
    all_attendees = self.attendees
    if all_attendees.size > 0
      update_column(:attendance_loss, ((Standing.where(active: true).size - all_attendees.size) * Settings.standing.delinquent_loss / all_attendees.size.to_f).round(6))
    end
  end

  def zone=(z)
    z = Zone.find(z) unless z.class == Zone
    super(z)
  end

  private

  def dates_are_consecutive
    unless ended_at.blank? || started_at.blank?
      if started_at > ended_at
        errors.add(:ended_at, 'cannot occur before Start Date.')
      end
    end
  end

  def destroy_standing_events
    self.standing_events.dominant.destroy_all
  end

  def ended_at_is_valid_datetime
    unless ended_at.blank?
      errors.add(:ended_at, 'must be a valid datetime') if ((TimeManagement.local(ended_at) rescue ArgumentError) == ArgumentError)
    end
  end

  def reset_processed
    update_column(:processed, false)
  end

  def started_at_is_valid_datetime
    errors.add(:started_at, 'must be a valid datetime') if ((TimeManagement.local(started_at) rescue ArgumentError) == ArgumentError)
  end
end
