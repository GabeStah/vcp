class BattleNet
  extend ActiveModel::Callbacks
  include ActiveModel::Model
  include Errors

  attr_accessor :type, :guild, :locale, :realm, :character_name
  attr_reader :errors
  define_model_callbacks :initialize

  after_initialize :validate

  validates :character_name,
            length: { minimum: 2, maximum: 250 },
            if: :type_is_character?
  validates :guild,
            length: { minimum: 3, maximum: 250 },
            if: :type_is_guild?
  validates :locale,
            inclusion: { in: %w( us eu kr tw US EU KR TW ) },
            length: { minimum: 2, maximum: 2 },
            presence: true
  validates :realm,
            presence: true
  validates :type,
            presence: true,
            inclusion: { in: %w( character CHARACTER guild GUILD ) }


  def character
    @character
  end

  def connected?
    @connected
  end

  def connect
    if self.valid?
      case @type.downcase
        when "character"
          @json = JSON.parse(Net::HTTP.get_response(URI.parse(URI.encode("http://#{@locale.downcase}.battle.net/api/wow/character/#{@realm.downcase}/#{@character_name}"))).body)
        when "guild"
          @json = JSON.parse(Net::HTTP.get_response(URI.parse(URI.encode("http://#{@locale.downcase}.battle.net/api/wow/guild/#{@realm.downcase}/#{@guild}?fields=members"))).body)
      end
      if @json['status'] == 'nok'
        errors.add(:battle_net_error, @json['reason'])
        #raise BattleNetError.new(message: @json['reason'])
      else
        @connected = true
      end
    end
    @auto_connect = false if @auto_connect
    @connected # return @connected to indicate success
  end

  def json
    @json
  end

  def initialize(args = {})
    run_callbacks :initialize do
      @auto_connect = args[:auto_connect] || false
      @character_name = args[:character_name]
      @connected = false
      @errors = ActiveModel::Errors.new(self)
      @guild = args[:guild]
      @locale = args[:locale]
      @realm = args[:realm]
      @type = args[:type] || 'guild'
      # connect if auto_connect set
      self.connect if @auto_connect
    end
  end

  def update
    if self.connected? && !@json.nil?
      case @type.downcase
        when "character"
          character = Character.find_or_initialize_by(name:   @json['name'],
                                                      locale: @locale,
                                                      realm:  @json['realm'])
          character.update_attributes(
              achievement_points: @json['achievementPoints'],
              character_class:    CharacterClass.find_or_initialize_by(blizzard_id: @json['class']) || 0,
              gender:             @json['gender'],
              level:              @json['level'],
              portrait:           @json['thumbnail'],
              race:               Race.find_or_initialize_by(blizzard_id: @json['race']) || 0
          )
          @character = character
          puts "Character Updated: #{@json['name']}"
        when "guild"
          @json['members'].each do |entry|
            battle_net = BattleNet.new(character_name: entry['character']['name'],
                                       locale:         @locale,
                                       realm:          entry['character']['realm'],
                                       type:           'character',
                                       auto_connect:   true)
            battle_net.update if battle_net.connected?
          end
      end
    end
  end

  private
    def type_is_character?
      self.type.downcase == 'character'
    end
    def type_is_guild?
      self.type.downcase == 'guild'
    end
    def validate
      self.valid?
    end
end