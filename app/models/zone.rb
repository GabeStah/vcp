class Zone < ActiveRecord::Base
  has_many :raids
  before_validation :ensure_zone_type_is_lowercase
  before_validation :ensure_blizzard_id_exists

  validates :blizzard_id,
            numericality: { only_integer: true }
  validates :name,
            presence: true,
            uniqueness: true
  validates :zone_type,
            allow_blank: true,
            inclusion: WOW_ZONE_TYPE_LIST

  def ensure_blizzard_id_exists
    self.blizzard_id = 0 if self.blizzard_id.nil?
  end
  def ensure_zone_type_is_lowercase
    self.zone_type = self.zone_type.downcase if self.zone_type
  end
end
