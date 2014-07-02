class Guild < ActiveRecord::Base
  include Errors
  has_many :characters

  after_initialize :defaults
  before_validation :ensure_region_is_downcase
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

  normalize_attributes :region
  normalize_attribute :battlegroup, :name, :realm, :with => :squish

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
        @json = JSON.parse(Net::HTTP.get_response(URI.parse(URI.encode("http://#{self.region.downcase}.battle.net/api/wow/guild/#{self.realm.downcase}/#{self.name}"))).body)
      when 'guild-members'
        @json = JSON.parse(Net::HTTP.get_response(URI.parse(URI.encode("http://#{self.region.downcase}.battle.net/api/wow/guild/#{self.realm.downcase}/#{self.name}?fields=members"))).body)
    end
    # Process json
    if @json['status'] == 'nok'
      raise BattleNetError.new(message: @json['reason'])
    else
      # Update record
      case type
        when 'guild'
          self.update_attributes(achievement_points: @json['achievementPoints'],
                                 battlegroup: @json['battlegroup'],
                                 level: @json['level'],
                                 side: @json['side'],
                                 verified: true)
          # Update guild members
          BattleNetWorker.perform_async(id: self.id, type: 'guild-members')
        when 'guild-members'
          @json['members'].each do |entry|
            # Create or lookup characterb
            character = Character.find_or_create_by(name: entry['character']['name'],
                                                    realm: entry['character']['realm'],
                                                    region: self.region)

            # Add guild record
            character.update_attributes(guild: self,
                                        rank: entry['rank'])
            # Create a character worker
            BattleNetWorker.perform_async(id: character.id, type: 'character')
          end
      end
    end
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
end