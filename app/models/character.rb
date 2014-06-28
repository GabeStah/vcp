class Character < ActiveRecord::Base
  belongs_to :character_class
  belongs_to :guild
  belongs_to :race
  before_validation :ensure_region_is_lowercase
  #after_initialize :defaults

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
  #     },
  #     "rank": 9
  # },

  # 1. Guild (Guild, Realm, Locale)
  # Character.new(guild, realm, locale)
  # 2. Guild Character (All)
  # Character.new(guild, realm, locale)
  # 3. Character (All less Guild/Rank)

  validates_associated :character_class, :guild, :race

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
  validates :region,
            format: { with: /[a-z]+/ },
            length: { minimum: 2, maximum: 2 },
            presence: true,
            uniqueness: { scope: [:name, :realm],
                          message: "plus Name plus Realm combination already exists",
                          case_sensitive: false }
  validates :portrait,
            format: { with: /\A[\w+d+-]+\/\d+\/\d+-avatar\.((jpg)|(png))\z/ },
            presence: true
  validates :name,
            format: { with: /\A[^\(\)0-9]*\z/ },
            presence: true,
            uniqueness: { scope: [:locale, :realm],
                          message: "plus Locale plus Realm combination already exists",
                          case_sensitive: false }
  validates :race,
            presence: true
  validates :rank,
            inclusion: { in: 0..12 },
            numericality: { only_integer: true },
            presence: true,
            allow_blank: true
  validates :realm,
            presence: true,
            uniqueness: { scope: [:locale, :name],
                          message: "plus Locale plus Name combination already exists",
                          case_sensitive: false }

  private
    def ensure_region_is_lowercase
      unless self.region.nil?
        self.region = self.region.downcase
      end
    end
end
