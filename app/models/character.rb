class Character < ActiveRecord::Base
  belongs_to :character_class
  belongs_to :race
end
