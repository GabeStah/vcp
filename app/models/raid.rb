class Raid < ActiveRecord::Base
  belongs_to :zone
  has_many :participations
  # Destroy participations associated with Raid
  has_many :characters, -> { uniq }, through: :participations, dependent: :delete_all
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
    #settings = Setting.first
    # Primary stage first
    self.characters.each do |character|
      # Find character participation set
      participations = self.participations.where(character: character).order(:timestamp)
      # Create StandingCalculation instance
      standing_calculation = StandingCalculation.new(character: character, participations: participations, raid: self, stage: :primary)
    end
    # Secondary stage
    secondary_stage(type: :delinquent_gain)
  end

  def secondary_stage(args={})
    stage_type = args[:type] || :delinquent_gain
    # Find all standing where active = true and created_at was prior to raid.started_at
    standings = Standing.created_before(self.started_at).where(active: true)
    case stage_type
      when :delinquent_gain
        # Find all delinquent_loss events for raid
        standing_events = StandingEvent.losses.where(raid: self, type: :delinquent)

        # If only one standing, originator is only target so no change
        if standings.size > 1
          # Loop through each event
          standing_events.each do |standing_event|
            # Loop through standings
            standings.each do |standing|
              # Make sure standing_event originator does not equal current updated standing character
              unless standing_event.standing.id == standing.id
                # Get divided value
                delinquent_gain = standing_event.change.to_f / (standings.size - 1)
                # Reverse polarization
                delinquent_gain *= -1
                # Create a StandingEvent with distributed value
                StandingEvent.create(raid: self,
                                     change: delinquent_gain,
                                     standing: standing,
                                     type: :delinquent)
              end
            end
          end
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
