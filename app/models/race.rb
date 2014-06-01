class Race < ActiveRecord::Base
  validates :name,
            presence: true,
            uniqueness: { case_sensitive: false }
  validate :name_must_be_camel_case

  def name_must_be_camel_case
    unless name == name.camelcase
      errors.add(:name, "must be CamelCase format.")
    end
  end
end