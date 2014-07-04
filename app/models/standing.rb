class Standing < ActiveRecord::Base
  belongs_to :character

  validates :character,
            presence: true,
            uniqueness: true
end
