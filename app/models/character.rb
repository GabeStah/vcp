class Character < ActiveRecord::Base
  belongs_to :character_class
  belongs_to :race
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

  validates :achievement_points,
            numericality: { only_integer: true },
            presence: true
  validates :character_class,
            presence: true
  validates :gender,
            inclusion: { in: [0, 1] },
            numericality: { only_integer: true },
            presence: true
  validates :guild,
            allow_blank: true,
            length: { minimum: 3, maximum: 250 }
  validates :level,
            inclusion: { in: 0..100 },
            numericality: { only_integer: true },
            presence: true
  validates :locale,
            format: { with: /[a-z]+/ },
            length: { minimum: 2, maximum: 2 },
            presence: true,
            uniqueness: { scope: [:name, :realm],
                          message: "plus Name plus Realm combination already exists",
                          case_sensitive: false }
  validates :portrait,
            format: { with: /[\w+d+-]+\/\d+\/\d+-avatar\.((jpg)|(png))/ },
            presence: true
  validates :name,
            format: { with: /\A[a-zA-Z]+\z/ },
            presence: true,
            uniqueness: { scope: [:locale, :realm],
                          message: "plus Locale plus Realm combination already exists",
                          case_sensitive: false }
  validates :race,
            presence: true
  validates :rank,
            inclusion: { in: 0..12 },
            numericality: { only_integer: true },
            presence: true
  validates :realm,
            presence: true,
            uniqueness: { scope: [:locale, :name],
                          message: "plus Locale plus Name combination already exists",
                          case_sensitive: false }

  def self.from_url(url)
    unless url.nil?
      json = JSON.parse(Net::HTTP.get_response(URI.parse(url)).body)
      puts json['members']
    end
  end

  def self.update_from_json(json, format = 'guild-character', locale = 'us', rank = 9)
    unless json.nil?
      case format
        when 'character'
          character = Character.find_or_initialize_by(name: json['name'],
                                                      locale: locale,
                                                      realm: json['realm'])
          character.achievement_points = json['achievementPoints']
          character.character_class = CharacterClass.find_by(blizzard_id: json['class']) || 0
          character.gender = json['gender']
          character.level = json['level']
          character.portrait = json['thumbnail']
          character.race = Race.find_by(blizzard_id: json['race']) || 0
          character.save
          character
        when 'guild-character'
          character = Character.find_or_initialize_by(name: json['name'],
                                                      locale: locale,
                                                      realm: json['realm'])
          character.achievement_points = json['achievementPoints']
          character.character_class = CharacterClass.find_by(blizzard_id: json['class']) || 0
          character.gender = json['gender']
          character.guild = json['guild']
          character.level = json['level']
          character.portrait = json['thumbnail']
          character.race = Race.find_by(blizzard_id: json['race']) || 0
          character.rank = rank
          character.save
          character
      end
    end
  end

  private
    def defaults
      self.achievement_points ||= 1500
      self.gender ||= 0
      self.guild ||= "Vox Immortalis"
      self.level ||= 90
      self.locale ||= 'us'
      self.portrait ||= "internal-record-3661/66/115044674-avatar.jpg"
      self.name ||= "Kulldar"
      self.rank ||= 5
      self.realm ||= "Hyjal"
    end
end
