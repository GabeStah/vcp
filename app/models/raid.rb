class Raid < ActiveRecord::Base
  belongs_to :zone
  has_many :participations
  # Destroy participations associated with Raid
  has_many :characters, through: :participations, dependent: :delete_all
  has_many :standing_events

  # ended_at
  validate :ended_at_is_valid_datetime
  validates :ended_at,
            allow_blank: true,
            uniqueness: true
  # started_at
  validates :started_at,
            presence: true,
            uniqueness: true
  validate :started_at_is_valid_datetime
  # Dates should be logical
  validate :dates_are_consecutive

  def add_participations_from_params(data)
    # Add participation records
    if data
      data.each do |id, status|
        in_raid = false
        online = false
        case status
          when PARTICIPATION_STATUS[:invited]
            in_raid = true
            online = true
          when  PARTICIPATION_STATUS[:online]
            in_raid = false
            online = true
          when  PARTICIPATION_STATUS[:excused]
            in_raid = false
            online = false
          when  PARTICIPATION_STATUS[:unexcused]
            in_raid = false
            online = false
        end
        self.participations.create(character: Character.find(id), in_raid: in_raid, online: online, timestamp: self.started_at)
      end
    end
  end


  def ended_at=(t)
    t = DateTime.strptime(t, DATETIME_FORMAT) unless t.blank? || t.class == DateTime || t.class == ActiveSupport::TimeWithZone
    super(t)
  end

  def full_title
    return "#{zone.name} @ #{I18n.l(started_at)}"
  end

  def process_standing_events
    settings = Setting.first
    # Loop characters to process
    # TODO: Character set is not accurate, instead is retrieving all participation records.
    self.characters.each do |character|
      # Find character participation set
      participations = self.participations.where(character: character).order(:timestamp)
      # IF: Character was online and in_raid between start settings.tardiness_cutoff_time
     if participations.detect do |participation|
          participation.online == true &&
          participation.in_raid == true &&
          participation.timestamp >= self.started_at &&
          participation.timestamp <= (self.started_at.to_time +
            (Rails.env.production? ? settings.tardiness_cutoff_time.minutes : DEFAULT_SITE_SETTINGS[:tardiness_cutoff_time])).to_datetime
     end
       # THEN: Attendance_loss
       @standing_event = StandingEvent.create(raid: self,
                                              change: -DEFAULT_SITE_SETTINGS[:attendance_cost],
                                              standing: Standing.find_by(character: character),
                                              type: :attendance)
       blah = true
     end
    end
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

  def ended_at_is_valid_datetime
    unless ended_at.blank?
      errors.add(:ended_at, 'must be a valid datetime') if ((DateTime.parse(ended_at.to_s) rescue ArgumentError) == ArgumentError)
    end
  end
  def started_at_is_valid_datetime
    errors.add(:started_at, 'must be a valid datetime') if ((DateTime.parse(started_at.to_s) rescue ArgumentError) == ArgumentError)
  end
end
