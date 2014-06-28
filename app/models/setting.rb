class Setting < ActiveRecord::Base
  validates :guild,
            length: { minimum: 3, maximum: 250 },
            presence: true
  validates :region,
            format: { with: /[A-Za-z]+/ },
            inclusion: WOW_REGION_LIST,
            length: { minimum: 2, maximum: 2 },
            presence: true
  validates :realm,
            presence: true
end
