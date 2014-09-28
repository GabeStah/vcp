class TimeManagement

  def self.local(value)
    # Nil of nil
    return nil if value.blank? || value.nil?
    # return value if appropriate class
    return value if value.class == ActiveSupport::TimeWithZone
    # check for AM/PM
    return Time.zone.strptime(value, DATETIME_FORMAT) if value.include?('AM') || value.include?('PM')
    # check for UTC
    return Time.zone.strptime(value, DATETIME_FORMAT_UTC) if value.include? 'UTC'
    # try parse
    begin
      return Time.zone.parse(value)
    rescue Exception => e
      nil
    end
  end
end