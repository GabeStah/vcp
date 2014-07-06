class Participation < ActiveRecord::Base
  belongs_to :character
  belongs_to :raid
end