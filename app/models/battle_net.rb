class BattleNet
  include ActiveModel::Model
  include Errors
  attr_accessor :type, :guild, :locale, :realm, :character_name
  attr_reader :errors
  validates :character_name,
            allow_blank: true,
            length: { minimum: 2, maximum: 250 }
  validates :guild,
            allow_blank: true,
            length: { minimum: 3, maximum: 250 }
  validates :locale,
            format: { with: /[A-Za-z]+/ },
            length: { minimum: 2, maximum: 2 },
            presence: true
  validates :realm,
            presence: true
  validates :type,
            presence: true,
            inclusion: { in: %w( character CHARACTER guild GUILD ) }


  def initialize
    @errors = ActiveModel::Errors.new(self)
  end

  # def validate!
  #   errors.add(:realm, "cannot be nil") if realm.nil?
  # end

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
end