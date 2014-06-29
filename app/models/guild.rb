class Guild < ActiveRecord::Base
  has_many :characters

  after_initialize :defaults
  before_validation :ensure_region_is_downcase
  before_save :reset_primary_flags

  validates :achievement_points,
            allow_blank: true,
            numericality: { only_integer: true }
  validates :active,
            inclusion: [true, false]
  validates :battlegroup,
            allow_blank: true,
            length: { minimum: 3, maximum: 250 }
  validates :level,
            allow_blank: true,
            numericality: { only_integer: true },
            presence: true
  validates :name,
            presence: true,
            length: { minimum: 3, maximum: 250 },
            uniqueness: { scope: [:realm, :region],
                          message: '+ Realm + Region combination already exists',
                          case_sensitive: false }
  validates :primary,
            inclusion: [true, false]
  validates :realm,
            presence: true
  validates :region,
            inclusion: WOW_REGION_LIST,
            length: { minimum: 2, maximum: 2 },
            presence: true
  validates :side,
            allow_blank: true,
            numericality: { only_integer: true, less_than_or_equal_to: 1}
  validates :verified,
            inclusion: [true, false]

  normalize_attributes :region
  normalize_attribute :battlegroup, :name, :realm, :with => :squish

  # Ensure only one primary record at a time
  # Find all guilds where primary: true, excluding current, and set primary: false
  def reset_primary_flags
    Guild.where.not(id: self).where(primary: true).update_all(primary: false) if self.primary?
  end

  private
    def defaults
      self.active = false if self.active.nil?
      self.primary = false if self.primary.nil?
      self.verified = false if self.verified.nil?
    end
    def ensure_region_is_downcase
      unless self.region.nil?
        self.region = self.region.downcase
      end
    end
end