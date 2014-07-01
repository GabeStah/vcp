class Character < ActiveRecord::Base
  include Errors
  include FriendlyId
  friendly_id :region_realm_name, use: [:finders, :slugged], sequence_separator: '/'
  belongs_to :character_class
  belongs_to :guild
  belongs_to :race
  before_validation :ensure_region_is_lowercase

  normalize_attributes :name, :portrait, :region
  normalize_attribute :realm, :with => :squish

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

  def self.find_by_param(param)
    find_by(name: param['name'],
            realm: param['realm'],
            region: param['region'])
  end

  def self.from_param(param)
    find_by(name: param['name'],
            realm: param['realm'],
            region: param['region'])
  end

  def params
    [region: region, realm: realm, name: name]
  end

  # #Alter the primary parameter from :id
  def to_param
    [region, realm, name].join('/')
  end

  def region_realm_name
    "#{region}/#{realm}/#{name}"
    #[region, realm, name].join('/')
  end

  def should_generate_new_friendly_id?
    name_changed? || region_changed? || realm_changed?
  end

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
          synced_at:          DateTime.now,
          verified:           true
      )
    end
  end

  private
    def ensure_region_is_lowercase
      unless self.region.nil?
        self.region = self.region.downcase
      end
    end
end
