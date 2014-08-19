class Raid < ActiveRecord::Base
  belongs_to :zone
  has_many :participations, dependent: :destroy
  # Destroy participations associated with Raid
  has_many :characters, -> { uniq }, through: :participations, dependent: :delete_all
  has_many :standing_events, dependent: :destroy

  before_update :destroy_standing_events
  before_update :reset_processed
  after_update :process_standing_events

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
          # Check online
          unless params['online'].nil? || params['online'][id].nil?
            online = true if params['online'][id][count] && params['online'][id][count] == '1'
          end
          # Check in_raid
          unless params['in_raid'].nil? || params['in_raid'][id].nil?
            in_raid = true if params['in_raid'][id][count] && params['in_raid'][id][count] == '1'
          end
          self.participations.create(character: Character.find(id), in_raid: in_raid, online: online, timestamp: timestamp)
        end
      end
    end
  end

  def ended_at=(t)
    t = DateTime.strptime(t, DATETIME_FORMAT) unless t.blank? || t.class == DateTime || t.class == ActiveSupport::TimeWithZone
    super(t)
  end

  def full_title
    "#{zone.name} @ #{I18n.l(started_at)}"
  end

  def process_standing_events
    #settings = Setting.first
    unless processed
      # Primary stage first
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

  def started_at=(t)
    t = DateTime.strptime(t, DATETIME_FORMAT) unless t.blank? || t.class == DateTime || t.class == ActiveSupport::TimeWithZone
    super(t)
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
      errors.add(:ended_at, 'must be a valid datetime') if ((DateTime.parse(ended_at.to_s) rescue ArgumentError) == ArgumentError)
    end
  end

  def reset_processed
    update_column(:processed, false)
  end

  def started_at_is_valid_datetime
    errors.add(:started_at, 'must be a valid datetime') if ((DateTime.parse(started_at.to_s) rescue ArgumentError) == ArgumentError)
  end
end
