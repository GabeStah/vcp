class StandingCalculation
  extend ActiveModel::Callbacks
  include ActiveModel::Validations

  define_model_callbacks :initialize, only: :after

  after_initialize :process_calculation

  validates :character,
            presence: true
  validates :participations,
            presence: true
  validates :raid,
            presence: true

  attr_accessor :character, :participations, :raid, :settings

  def calculate(args = {})
    tardiness_cutoff_time = Rails.env.production? ? settings.tardiness_cutoff_time : DEFAULT_SITE_SETTINGS[:tardiness_cutoff_time]
    case args[:type]
      when :attendance_loss
        # Character was online and in_raid between start and start+settings.tardiness_cutoff_time
        in_raid = first_time(event: :in_raid, during_raid: true, within_cutoff: true)
        online = first_time(event: :online, during_raid: true, within_cutoff: true)
        # VALUE: attendance_loss
        return DEFAULT_SITE_SETTINGS[:attendance_loss] if (in_raid.present? && online.present?)
      when :attendance_gain
        # Character was online between start and start+settings.tardiness_cutoff_time
        online = first_time(event: :online, during_raid: true, within_cutoff: true)
        # AND
        # Character was never in_raid between start and start+settings.tardiness_cutoff_time
        in_raid = first_time(event: :in_raid, during_raid: true, within_cutoff: true)
        # VALUE: attendance_gain
        return DEFAULT_SITE_SETTINGS[:attendance_gain] if (online.present? && in_raid.nil?)
      when :delinquent_loss
        online = first_time(event: :online, during_raid: true)
        # Character was never online during raid
        if online.nil?
          # VALUE: delinquent_loss
          return DEFAULT_SITE_SETTINGS[:delinquent_loss]
        end
        # OR
        # Character was online after raid_start
        if online.present? && (online.to_datetime > raid.started_at.to_datetime)
          return DEFAULT_SITE_SETTINGS[:delinquent_loss]
        end
    end
  end

  def first_time(args = {})
    tardiness_cutoff_time = Rails.env.production? ? settings.tardiness_cutoff_time : DEFAULT_SITE_SETTINGS[:tardiness_cutoff_time]
    # Check only for first event that falls within raid timeframe
    during_raid = args[:during_raid].present? ? args[:during_raid] : true
    within_cutoff = args[:within_cutoff].present? ? args[:within_cutoff] : false
    case args[:event]
      when :in_raid
        participations.each do |participation|
          if within_cutoff
            return participation.timestamp if participation.matches_filter?(in_raid: true, after: raid.started_at, before: (raid.started_at.to_time + tardiness_cutoff_time.minutes).to_datetime)
          elsif during_raid
            return participation.timestamp if participation.matches_filter?(in_raid: true, after: raid.started_at, before: raid.ended_at)
          else
            return participation.timestamp if participation.matches_filter?(in_raid: true)
          end
        end
      when :online
        participations.each do |participation|
          if within_cutoff
            return participation.timestamp if participation.matches_filter?(online: true, after: raid.started_at, before: (raid.started_at.to_time + tardiness_cutoff_time.minutes).to_datetime)
          elsif during_raid
            return participation.timestamp if participation.matches_filter?(online: true, after: raid.started_at, before: raid.ended_at)
          else
            return participation.timestamp if participation.matches_filter?(online: true)
          end
        end
    end
    nil # Return nil if no matches found
  end

  def initialize(attributes = {})
    run_callbacks :initialize do
      @attributes = attributes
      @character = attributes[:character]
      # Extract participations from raid if needed
      if attributes[:participations]
        @participations = attributes[:participations]
      else
        @participations = attributes[:raid].participations.where(character: attributes[:character]).order(:timestamp)
      end
      @raid = attributes[:raid]
      @settings = Setting.first
    end
  end

  def process_calculation
    attendance_loss = calculate(type: :attendance_loss)
    StandingEvent.create(raid: raid,
                         change: attendance_loss,
                         standing: Standing.find_by(character: character),
                         type: :attendance) if attendance_loss
    attendance_gain = calculate(type: :attendance_gain)
    StandingEvent.create(raid: raid,
                         change: attendance_gain,
                         standing: Standing.find_by(character: character),
                         type: :attendance) if attendance_gain
    delinquent_loss = calculate(type: :delinquent_loss)
    StandingEvent.create(raid: raid,
                         change: delinquent_loss,
                         standing: Standing.find_by(character: character),
                         type: :delinquent) if delinquent_loss
  end

  def read_attribute_for_validation(key)
    @attributes[key]
  end
end