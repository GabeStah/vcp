#require 'uri'

class Character < ActiveRecord::Base
  belongs_to :character_class
  belongs_to :race

  # {
  #     "character": {
  #     "name": "Sonodesu",
  #     "realm": "Hyjal",
  #     "battlegroup": "Vengeance",
  #     "class": 8,
  #     "race": 5,
  #     "gender": 0,
  #     "level": 80,
  #     "achievementPoints": 0,
  #     "thumbnail": "internal-record-3661/101/114196581-avatar.jpg",
  #     "guild": "Vox Immortalis",
  #     "guildRealm": "Hyjal"
  # },
  #     "rank": 9
  # },

  validates :achievement_points,
            numericality: { only_integer: true },
            presence: true
  validates :character_class,
            presence: true
  validates :gender,
            inclusion: { in: [0, 1] },
            numericality: { only_integer: true },
            presence: true
  validates :level,
            inclusion: { in: 0..100 },
            numericality: { only_integer: true },
            presence: true
  validates :portrait,
            format: { :with => /internal-record-\d+\/\d+\/\d+-avatar.jpg|png/ },
            presence: true
  validates :name,
            format: { :with => /\A[a-zA-Z]+\z/ },
            presence: true
  validates :race,
            presence: true
  validates :rank,
            inclusion: { in: 0..12 },
            numericality: { only_integer: true },
            presence: true
  validates :realm,
            presence: true

end
