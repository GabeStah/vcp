class CharacterClass < ActiveRecord::Base
  has_many :characters
  validates :blizzard_id,
            presence: true,
            uniqueness: true
  validates :name,
            uniqueness: { case_sensitive: false },
            presence: true
  validate :name_must_be_titleized

  normalize_attributes :name

  def short_name
    name.gsub(/\s+/, '').downcase
  end

  def name_must_be_titleized
    unless name.nil?
      unless name == name.titleize
        errors.add(:name, "must be in Titleized format.")
      end
    end
  end
end