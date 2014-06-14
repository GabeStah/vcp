class BattleNet
  extend ActiveModel::Callbacks
  include ActiveModel::Model
  include Errors
  define_model_callbacks :initialize
  attr_accessor :type, :guild, :locale, :realm, :character_name
  attr_reader :errors

  after_initialize :validate, :connect

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
  end

  def json
    @json
  end

  def initialize(args = {})
    run_callbacks :initialize do
      @character_name = args[:character_name]
      @connected = false
      @guild = args[:guild]
      @locale = args[:locale]
      @realm = args[:realm]
      @type = args[:type] || 'guild'
      @errors = ActiveModel::Errors.new(self)
    end
  end

  def update
    if self.valid? && self.connected?
      case @type.downcase
        when "guild"
          unless @json.nil?
            # loop json members
            json['members'].each do |member|
              #TODO: Update Character creation code
              #Character.update_from_json(member['character'], 'guild-character', @locale.downcase, member['rank'])
            end
          end
      end
    end
  end

  def to_json
    if self.valid?
      case @type.downcase
        when "character"
          json = JSON.parse(Net::HTTP.get_response(URI.parse(URI.encode("http://#{@locale.downcase}.battle.net/api/wow/character/#{@realm.downcase}/#{@character_name}"))).body)
          if json['status'] == 'nok'
            raise BattleNetError.new(message: json['reason'])
          end
          json
        when "guild"
          json = JSON.parse(Net::HTTP.get_response(URI.parse(URI.encode("http://#{@locale.downcase}.battle.net/api/wow/guild/#{@realm.downcase}/#{@guild}?fields=members"))).body)
          if json['status'] == 'nok'
            raise BattleNetError.new(message: json['reason'])
          end
          json
      end
    end
  end

  def populate_database
    if self.valid?
      case @type.downcase
        when "guild"
          json = self.to_json
          unless json.nil?
            if json['status'] == 'nok'
              raise BattleNetError.new(message: json['reason'])
            else
              # loop json members
              json['members'].each do |member|
                Character.update_from_json(member['character'], 'guild-character', @locale.downcase, member['rank'])
              end
            end
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