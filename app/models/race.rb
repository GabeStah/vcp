class Race < ActiveRecord::Base
  has_many :characters
  validates :blizzard_id,
            numericality: { only_integer: true },
            presence: true,
            uniqueness: { scope: :name,
                          message: "plus Name combination already exists" }
  validates :name,
            presence: true,
            uniqueness: { scope: :blizzard_id,
                          message: "plus Blizzard ID combination already exists",
                          case_sensitive: false }
  validates :side,
            presence: true,
            format: { with: /[a-z]+/, message: 'must be lowercase' }
  validate :name_must_be_titleized

  normalize_attribute :name, :side, :with => :squish

  def name_must_be_titleized
    unless name.nil?
      unless name == name.titleize
        errors.add(:name, "must be in Titleized format.")
      end
    end
  end
end