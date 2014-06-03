class CharacterClass < ActiveRecord::Base
  has_many :characters
  validates :name,
            presence: true,
            uniqueness: { case_sensitive: false }
  validate :name_must_be_titleized

  def name_must_be_titleized
    unless name == name.titleize
      errors.add(:name, "must be in Titleized format.")
    end
  end
end