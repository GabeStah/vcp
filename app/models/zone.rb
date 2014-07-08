class Zone < ActiveRecord::Base
  has_many :raids
  before_validation :ensure_zone_type_is_lowercase

  validates :blizzard_id,
            allow_blank: true,
            numericality: true
  validates :name,
            presence: true,
            uniqueness: true
  validates :zone_type,
            allow_blank: true,
            inclusion: WOW_ZONE_TYPE_LIST

  def ensure_zone_type_is_lowercase
    unless self.zone_type.nil?
      self.zone_type = self.zone_type.downcase
    end
  end
end
