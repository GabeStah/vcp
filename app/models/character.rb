class Character < ActiveRecord::Base
  include Errors
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
            allow_blank: true,
            numericality: { only_integer: true }
  validates :gender,
            allow_blank: true,
            inclusion: [0, 1],
            numericality: { only_integer: true }
  validates :level,
            allow_blank: true,
            inclusion: 0..100,
            numericality: { only_integer: true }
  validates :portrait,
            allow_blank: true,
            format: { with: /\A[\w+d+-]+\/\d+\/\d+-avatar\.((jpg)|(png))\z/ }
  validates :name,
            format: { with: /\A[^\(\)0-9]*\z/ },
            presence: true,
            uniqueness: { scope: [:region, :realm],
                          message: "+ Realm + Region combination already exists",
                          case_sensitive: false }
  validates :rank,
            allow_blank: true,
            inclusion: { in: 0..12 },
            numericality: { only_integer: true }
  validates :realm,
            presence: true
  validates :region,
            inclusion: WOW_REGION_LIST,
            presence: true

  normalize_attributes :name, :portrait, :region
  normalize_attribute :realm, :with => :squish

  # Update data from Battle.net
  def update_from_battle_net
    # Establish connection
    # Retrieve json
    @json = JSON.parse(Net::HTTP.get_response(URI.parse(URI.encode("http://#{self.region.downcase}.battle.net/api/wow/character/#{self.realm.downcase}/#{self.name}"))).body)
    # Process json
    if @json['status'] == 'nok'
      unless @json['reason'] == 'Character not found.'
        raise CharacterError.new(message: @json['reason'],
                                 name: self.name,
                                 realm: self.realm,
                                 region: self.region)
      end
    else
      # Update record
      self.update_attributes(
          achievement_points: @json['achievementPoints'],
          character_class:    CharacterClass.find_by(blizzard_id: @json['class']),
          gender:             @json['gender'],
          level:              @json['level'],
          portrait:           @json['thumbnail'],
          race:               Race.find_by(blizzard_id: @json['race']),
          verified:           true
      )
      puts "Character Updated: #{self.name}"
    end
  end

  private
    def ensure_region_is_lowercase
      unless self.region.nil?
        self.region = self.region.downcase
      end
    end
end
