class Guild < ActiveRecord::Base
  include Errors
  has_many :characters

  after_initialize :defaults
  before_validation :ensure_region_is_downcase
  before_validation :generate_slug
  before_save :reset_primary_flags
  after_create :generate_battle_net_worker

  validates :achievement_points,
            allow_blank: true,
            numericality: { only_integer: true }
  validates :active,
            inclusion: [true, false]
  validates :battlegroup,
            allow_blank: true,
            length: { minimum: 3, maximum: 250 }
  validates :level,
            allow_blank: true,
            numericality: { only_integer: true },
            presence: true
  validates :name,
            presence: true,
            length: { minimum: 3, maximum: 250 },
            uniqueness: { scope: [:realm, :region],
                          message: '+ Realm + Region combination already exists',
                          case_sensitive: false }
  validates :primary,
            inclusion: [true, false]
  validates :realm,
            presence: true
  validates :region,
            inclusion: WOW_REGION_LIST,
            length: { minimum: 2, maximum: 2 },
            presence: true
  validates :side,
            allow_blank: true,
            numericality: { only_integer: true, less_than_or_equal_to: 1}
  validates :verified,
            inclusion: [true, false]
  validates :slug,
            presence: true,
            uniqueness: { case_sensitive: false }

  normalize_attributes :region
  normalize_attribute :battlegroup, :name, :realm, :with => :squish

  def self.find(input)
    input.class != self && input.to_i == 0 ? find_by(slug: input.downcase) : super
  end

  # Ensure only one primary record at a time
  # Find all guilds where primary: true, excluding current, and set primary: false
  def reset_primary_flags
    Guild.where.not(id: self).where(primary: true).update_all(primary: false) if self.primary?
  end

  # Update data from Battle.net
  def update_from_battle_net(type: 'guild')
    # Establish connection
    # Retrieve json
    case type
      when 'guild'
        @json = JSON.parse(Net::HTTP.get_response(URI.parse(URI.encode("https://#{self.region.downcase}.#{Settings.api.domain}/wow/guild/#{self.realm.downcase}/#{self.name}?apikey=#{ENV['battle_net_api_key']}"))).body)
      when 'guild-members'
        @json = JSON.parse(Net::HTTP.get_response(URI.parse(URI.encode("https://#{self.region.downcase}.#{Settings.api.domain}/wow/guild/#{self.realm.downcase}/#{self.name}?fields=members&apikey=#{ENV['battle_net_api_key']}"))).body)
    end
    # Process json
    if @json['status'] == 'nok'
      raise BattleNetError.new(message: @json['reason'])
    else
      # Update record
      case type
        when 'guild'
          self.update(achievement_points: @json['achievementPoints'],
                                 battlegroup: @json['battlegroup'],
                                 level: @json['level'],
                                 side: @json['side'],
                                 verified: true)
          # Update guild members
          BattleNetWorker.perform_async(id: self.id, type: 'guild-members')
        when 'guild-members'
          @json['members'].each do |entry|

            character = Character.find_by(name: entry['character']['name'],
                                          realm: entry['character']['realm'],
                                          region: self.region)
            if character
              # Add guild record
              character.update(guild: self,
                               rank: entry['rank'])
              # Create a character worker
              BattleNetWorker.perform_async(id: character.id, type: 'character')
            else
              # Create
              # Create or lookup character
              character = Character.create(name: entry['character']['name'],
                                           realm: entry['character']['realm'],
                                           region: self.region)

              # Add guild record
              character.update(guild: self,
                               rank: entry['rank'])
              # DO NOT create a worker, worker is created through Character model
            end
          end
      end
    end
  end

  # #Alter the primary parameter from :id
  def to_param
    slug
  end

  private
    def defaults
      self.active = false if self.active.nil?
      self.primary = false if self.primary.nil?
      self.verified = false if self.verified.nil?
    end
    def ensure_region_is_downcase
      unless self.region.nil?
        self.region = self.region.downcase
      end
    end
    def generate_battle_net_worker
      BattleNetWorker.perform_async(id: self.id, type: 'guild')
    end
    def generate_slug
      self.slug = [region, realm, name].join(' ').gsub(/\s+/, '-').downcase
    end
end