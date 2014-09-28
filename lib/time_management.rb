class TimeManagement

  def self.local(value)
    # Nil of nil
    return nil if value.blank? || value.nil?
    # return value if appropriate class
    return value if value.class == Time || value.class == ActiveSupport::TimeWithZone
    # try parse
    begin
      return Time.zone.parse(value)
    rescue Exception => e
      # check for AM/PM
      return Chronic.parse(value) if value.include?('AM') || value.include?('PM')
      # check for UTC
      return Chronic.parse(value) if value.include? 'UTC'
    end
  end

  def self.raid_end(format: nil)
    now = Time.zone.now
    output = Time.local(now.year, now.month, now.day, Settings.raid.end_time.hour, Settings.raid.end_time.min)
    if format
      return output.strftime(format)
    end
    return output
  end

  def self.raid_start(format: nil)
    now = Time.zone.now
    output = Time.local(now.year, now.month, now.day, Settings.raid.start_time.hour, Settings.raid.start_time.min)
    if format
      return output.strftime(format)
    end
    return output
  end

  def self.time_diff(t1, t2)
    if t1 > t2
      seconds_diff = (t1 - t2).to_i.abs
    elsif t2 > t1
      seconds_diff = (t2 - t1).to_i.abs
    else
      return 0
    end

    hours = seconds_diff / 3600
    seconds_diff -= hours * 3600

    minutes = seconds_diff / 60
    seconds_diff -= minutes * 60

    seconds = seconds_diff

    "#{hours.to_s.rjust(2, '0')}:#{minutes.to_s.rjust(2, '0')}:#{seconds.to_s.rjust(2, '0')}"
  end

end