class Character < ActiveRecord::Base
  require "open-uri"

  include Errors
  include SessionsHelper
  belongs_to :character_class
  belongs_to :guild
  belongs_to :race
  belongs_to :user

  has_many :participations
  # Delete participations associated with Character
  # Unique raids only
  has_many :raids, -> {uniq}, through: :participations, dependent: :delete_all
  # Delete standing associated with Character
  has_one :standing, dependent: :restrict_with_error
  before_validation :ensure_region_is_lowercase
  before_validation :generate_slug
  after_create :generate_battle_net_worker

  has_attached_file :avatar, default_url: "/images/:style/missing_avatar.png"
  has_attached_file :portrait, default_url: "/images/:style/missing_portrait.png"
  validates_attachment_content_type :avatar, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif"]
  validates_attachment_content_type :portrait, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif"]

  scope :claimed, ->(user) { where(user: user) }
  scope :unclaimed, ->(user) { where('user_id != ? OR user_id IS NULL', user).where(verified: true) }

  normalize_attributes :name, :region
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

  # Counters
  define_counter_cache :raids_count do |character|
    character.raids.count
  end
  update_counter_cache :user, :characters_count
  update_counter_cache :user, :characters_verified_count

  def download_file(url)
    open(URI.parse(url))
  rescue => e # catch url errors with validations instead of exceptions (Errno::ENOENT, OpenURI::HTTPError, etc...)
    nil
  end

  def self.find(input)
    input.to_i == 0 ? find_by(slug: input.downcase) : super
  end

  def full_title
    "#{self.name} of #{self.realm}-#{self.region.upcase}"
  end

  def joined_guild_at
    created_at
  end

  # determine if passed key (user_key + character_key) = combined
  def key_match?(passed_key, user)
    return false unless passed_key
    passed_key == process_key(user.secret_key)
  end

  # Retrieve the full portrait path
  def portrait_url(id, full = false)
    if full
      "http://#{self.region.downcase}.battle.net/static-render/#{self.region.downcase}/#{id.sub!('avatar', 'profilemain')}"
    else
      "http://#{self.region.downcase}.battle.net/static-render/#{self.region.downcase}/#{id}"
    end
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
    processed
  end

  # #Alter the primary parameter from :id
  def to_param
    slug
  end

  # Update data from Battle.net
  def update_from_battle_net
    # Establish connection
    # Retrieve json
    @json = JSON.parse(Net::HTTP.get_response(URI.parse(URI.encode("https://#{self.region.downcase}.#{Settings.api.domain}/wow/character/#{self.realm.downcase}/#{self.name}?fields=guild&apikey=#{ENV['battle_net_api_key']}"))).body)
    # Process json
    if @json['status'] == 'nok'
      unless @json['reason'] == 'Character not found.'
        raise CharacterError.new(message: @json['reason'],
                                 name: self.name,
                                 realm: self.realm,
                                 region: self.region)
      end
    else
      # Assign guild if it exists
      guild = Guild.find_or_create_by(name:   @json['guild']['name'],
                                      realm:  self.realm,
                                      region: self.region.downcase) if @json['guild'] && @json['guild']['name']
      # Update record
      update_attributes(
          achievement_points: @json['achievementPoints'],
          avatar:             download_file(portrait_url(@json['thumbnail'])),
          character_class:    CharacterClass.find_by(blizzard_id: @json['class']),
          gender:             @json['gender'],
          guild:              guild,
          level:              @json['level'],
          portrait:           download_file(portrait_url(@json['thumbnail'], true)),
          race:               Race.find_by(blizzard_id: @json['race']),
          synced_at:          Time.zone.now,
          verified:           true
      )
    end
  end

  private

  def ensure_region_is_lowercase
    self.region = self.region.downcase if self.region
  end
  def generate_battle_net_worker
    BattleNetWorker.perform_async(id: self.id, type: 'character')
  end
  def generate_slug
    self.slug = [region, realm, name].join(' ').gsub(/\s+/, '-').downcase
  end
end
