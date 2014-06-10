class Setting < ActiveRecord::Base
  validates :guild,
            length: { minimum: 3, maximum: 250 },
            presence: true
  validates :locale,
            format: { with: /[A-Za-z]+/ },
            length: { minimum: 2, maximum: 2 },
            presence: true
  validates :realm,
            presence: true
end
