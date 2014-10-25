class StandingCalculation
  extend ActiveModel::Callbacks
  include ActiveModel::Validations

  define_model_callbacks :initialize, only: :after

  after_initialize :process_calculation, unless: -> { self.skip_process }

  validates :character,
            presence: true
  validates :participations,
            presence: true
  validates :raid,
            presence: true

  attr_accessor :character, :participations, :raid

  def calculate(args = {})
    tardiness_cutoff_time = Settings.cutoff.tardy
    case args[:type]
      when :attendance_loss
        # Character was online and in_raid between start and start+settings.tardiness_cutoff_time
        in_raid = first_time(event: :in_raid, during_raid: true, within_cutoff: true)
        online = first_time(event: :online, during_raid: true, within_cutoff: true)
        # AND
        # Character qualified for attendance
        return raid.attendance_loss if (in_raid.present? && online.present? && qualified_for_attendance?)
      when :attendance_gain
        # Character was online between start and start+settings.tardiness_cutoff_time
        online = first_time(event: :online, during_raid: true, within_cutoff: true)
        # AND
        # Character was never in_raid between start and start+settings.tardiness_cutoff_time
        in_raid = first_time(event: :in_raid, during_raid: true, within_cutoff: true)
        # VALUE: attendance_gain
        return Settings.standing.attendance_gain if (online.present? && in_raid.nil?)
      when :delinquent_loss
        online = first_time(event: :online, during_raid: true)
        # Character was never online during raid
        if online.nil?
          # VALUE: delinquent_loss
          return Settings.standing.delinquent_loss
        end
        # OR
        # Character was online after raid_start
        if online.present? && (online > raid.started_at)
          if online <= (raid.started_at + tardiness_cutoff_time.minutes)
            tardiness_percent = (online.to_f - raid.started_at.to_f) / (tardiness_cutoff_time * 60)
            # VALUE: delinquent_loss * percent_of_cutoff_missed
            return (Settings.standing.delinquent_loss * tardiness_percent)
          else
            # Character missed entire tardiness cutoff period
            # VALUE: delinquent_loss
            return Settings.standing.delinquent_loss
          end
        end
        # OR
        # Character qualified for attendance but was offline sometime during cutoff period
        if qualified_for_attendance?
          cutoff_time_online = time_online(within_cutoff: true)
          cutoff_time_offline = (tardiness_cutoff_time * 60) - cutoff_time_online
          # If more than delinquent_cutoff_time minutes, qualify for absence and penalize cutoff period % of delinquency
          if (cutoff_time_offline / 60) >= Settings.cutoff.delinquent
            tardiness_percent = cutoff_time_offline.to_f / (Settings.cutoff.tardy * 60)
            return (Settings.standing.delinquent_loss * tardiness_percent)
          end
        end
    end
  end

  def first_time(args = {})
    tardiness_cutoff_time = Rails.env.production? ? settings.tardiness_cutoff_time : Settings.cutoff.tardy
    # Check only for first event that falls within raid timeframe
    during_raid = args[:during_raid].present? ? args[:during_raid] : true
    within_cutoff = args[:within_cutoff].present? ? args[:within_cutoff] : false
    case args[:event]
      when :in_raid
        participations.each do |participation|
          if within_cutoff
            return participation.timestamp if participation.matches_filter?(in_raid: true, after: raid.started_at, before: (raid.started_at + tardiness_cutoff_time.minutes))
          elsif during_raid
            return participation.timestamp if participation.matches_filter?(in_raid: true, after: raid.started_at, before: raid.ended_at)
          else
            return participation.timestamp if participation.matches_filter?(in_raid: true)
          end
        end
      when :online
        participations.each do |participation|
          if within_cutoff
            return participation.timestamp if participation.matches_filter?(online: true, after: raid.started_at, before: (raid.started_at + tardiness_cutoff_time.minutes))
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
      @skip_process = attributes[:skip_process]
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

  def qualified_for_attendance?
    attendance_cutoff_time = Rails.env.production? ? settings.tardiness_cutoff_time : Settings.cutoff.attendance
    raid_time = time_in_raid
    # Time in raid (min) meets/exceeds attendance_cutoff_time
    # OR
    # Time in raid longer greater than or equal to total raid time
    if raid_time.nil?
      return false
    elsif (raid_time / 60) >= attendance_cutoff_time || raid_time >= (raid.ended_at.to_i - raid.started_at.to_i)
      return true
    end
    false
  end

  def read_attribute_for_validation(key)
    @attributes[key]
  end

  def skip_process
    @skip_process
  end

  def time_in_raid
    in_raid = first_time(event: :in_raid, during_raid: true)
    total_time = 0
    previous_timestamp = nil
    unless in_raid.nil?
      # Loop participations, record if online + in raid time until next event
      participations.each do |participation|
        # if previous timestamp, check if current one changes status
        if previous_timestamp
          # Not in raid
          if participation.matches_filter?(in_raid: false) || participation.matches_filter?(online: false)
            # Add difference to total time and nil previous
            total_time += (participation.timestamp.to_i - previous_timestamp.to_i)
            previous_timestamp = nil
          else # still online and in_raid
            # Check if occurs after raid_end
            if participation.matches_filter?(after: raid.ended_at)
              # Add previous timestamp to raid_end to total time then nil out
              total_time += (raid.ended_at.to_i - previous_timestamp.to_i)
              previous_timestamp = nil
            end
          end
        else
          # If not previous timestamp, check if current matches online/in_raid filter
          if participation.matches_filter?(online: true, in_raid: true, after: raid.started_at, before: raid.ended_at)
            # Match, assign previous_timestamp
            previous_timestamp = participation.timestamp
          end
        end
      end
    end
    # If previous_timestamp still exists, add time to end of raid to total
    total_time += (raid.ended_at.to_i - previous_timestamp.to_i) if previous_timestamp
    # If total_time is 0, then nil
    total_time == 0 ? nil : total_time
  end

  def time_online(args={})
    tardiness_cutoff_time = Rails.env.production? ? settings.tardiness_cutoff_time : Settings.cutoff.tardy
    within_cutoff = args[:within_cutoff].present? ? args[:within_cutoff] : true
    online = first_time(event: :online, during_raid: true, within_cutoff: within_cutoff)
    total_time = 0
    previous_timestamp = nil
    unless online.nil?
      # Loop participations, record if online + in raid time until next event
      participations.each do |participation|
        # if previous timestamp, check if current one changes status
        if previous_timestamp
          # If cutoff set, limit range
          if within_cutoff
            # Within cutoff
            if participation.matches_filter?(after: raid.started_at, before: (raid.started_at + tardiness_cutoff_time.minutes))
              # If offline, new timestamp
              # If online, do nothing
              if participation.matches_filter?(online: false)
                total_time += (participation.timestamp.to_i - previous_timestamp.to_i)
                previous_timestamp = nil
              end
            else # After cutoff
              # Add up to cutoff time
              total_time += (participation.timestamp.to_i - previous_timestamp.to_i)
              previous_timestamp = nil
            end
          else
            if participation.matches_filter?(online: false)
              # Add difference to total time and nil previous
              total_time += ((raid.started_at + tardiness_cutoff_time.minutes).to_i - previous_timestamp.to_i)
              previous_timestamp = nil
            else # still online
              # Check if occurs after raid_end
              if participation.matches_filter?(after: raid.ended_at)
                # Add previous timestamp to raid_end to total time then nil out
                total_time += (raid.ended_at.to_i - previous_timestamp.to_i)
                previous_timestamp = nil
              end
            end
          end
        else
          # Check for cutoff flag
          if within_cutoff
            if participation.matches_filter?(online: true, after: raid.started_at, before: (raid.started_at + tardiness_cutoff_time.minutes))
              # Match, assign previous_timestamp
              previous_timestamp = participation.timestamp
            end
          else
            if participation.matches_filter?(online: true, after: raid.started_at, before: raid.ended_at)
              # Match, assign previous_timestamp
              previous_timestamp = participation.timestamp
            end
          end
        end
      end
    end
    # Cutoff flag
    if within_cutoff
      # If previous_timestamp still exists, add time to end of cutoff time
      total_time += ((raid.started_at + tardiness_cutoff_time.minutes).to_i - previous_timestamp.to_i) if previous_timestamp
    else # Check entire raid
      # If previous_timestamp still exists, add time to end of raid to total
      total_time += (raid.ended_at.to_i - previous_timestamp.to_i) if previous_timestamp
    end
    # If total_time is 0, then nil
    total_time == 0 ? nil : total_time
  end
end