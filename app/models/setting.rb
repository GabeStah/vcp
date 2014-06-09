class Setting < ActiveRecord::Base

  def self.get(name)
    entry = self.find(name: name).first
    return nil unless entry
    case entry.data_type
      when "Fixnum"
        return entry.value.to_i
      when "Float"
        return entry.value.to_f
      #add whatever other data types u want
    end
    entry.value
  end

  def self.set(name,value)
    entry = self.find_or_create_by(name: name)
    entry.value = value
    entry.data_type = value.class.to_s
    entry.save
  end
end