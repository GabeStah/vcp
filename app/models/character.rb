class Character < ActiveRecord::Base
  include Errors
  include SessionsHelper
  belongs_to :character_class
  belongs_to :guild
  belongs_to :race
  belongs_to :user
  before_validation :ensure_region_is_lowercase
  before_validation :generate_slug

  normalize_attributes :name, :portrait, :region
  normalize_attribute :realm, :with => :squish

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
  validates :slug,
            presence: true,
            uniqueness: { case_sensitive: false }

  def self.find(input)
    input.to_i == 0 ? find_by(slug: input) : super
  end

  # determine if passed key (user_key + character_key) = combined
  def key_match?(passed_key, user)
    return false unless passed_key
    return passed_key == process_key(user.secret_key)
  end

  def process_key(user_key)
    return nil unless user_key
    processed = user_key
    150.times do |count|
      case (count % 4)
        when 0
          processed = Digest::SHA2.hexdigest("#{processed}#{user_key}")
        when 1
          processed = Digest::SHA2.hexdigest("#{processed}#{self.slug}")
        when 2
          processed = Digest::SHA2.hexdigest("#{processed}#{user_key}#{self.slug}")
        when 3
          processed = Digest::SHA2.hexdigest("#{processed}#{self.slug}#{user_key}")
      end
    end
    return processed
  end

  # Retrieve the full portrait path
  def portrait_url(full = false)
    if full
      "http://#{self.region.downcase}.battle.net/static-render/#{self.region.downcase}/#{self.portrait.sub!('avatar', 'profilemain')}"
    else
      "http://#{self.region.downcase}.battle.net/static-render/#{self.region.downcase}/#{self.portrait}"
    end
  end

  # #Alter the primary parameter from :id
  def to_param
    slug
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
    def generate_slug
      self.slug = [region, realm, name].join(' ').gsub(/\s+/, '-').downcase
    end
end
