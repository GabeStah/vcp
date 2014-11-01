class TimeManagement

  def self.time_from_regex(value)
    begin
      parsed = Time.zone.strptime(value, DATETIME_FORMAT)
      if parsed
        month    = value[/#{DATETIME_EXTRACT_REGEX}/m, 1].to_s.to_i
        day      = value[/#{DATETIME_EXTRACT_REGEX}/m, 2].to_s.to_i
        year     = value[/#{DATETIME_EXTRACT_REGEX}/m, 3].to_s.to_i
        hour     = value[/#{DATETIME_EXTRACT_REGEX}/m, 4].to_s.to_i
        minute   = value[/#{DATETIME_EXTRACT_REGEX}/m, 5].to_s.to_i
        meridian = value[/#{DATETIME_EXTRACT_REGEX}/m, 6].to_s
        hour += 12 if meridian == 'PM'

        return Time.zone.local(year, month, day, hour, minute)
      end
    rescue Exception => e
      return nil
    end
    nil
  end

  def self.local(value)
    # Nil of nil
    return nil if value.blank? || value.nil?
    # return value if appropriate class
    return value if value.class == Time || value.class == ActiveSupport::TimeWithZone
    # try specific datetime format
    formatted = self.time_from_regex(value)
    return formatted if formatted

    # try parse
    begin
      return Time.zone.parse(value)
    rescue Exception => e2
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