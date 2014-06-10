class BattleNet
  include ActiveModel::Model
  attr_accessor :type, :guild, :locale, :realm
  validates :guild,
            length: { minimum: 3, maximum: 250 }
  validates :locale,
            format: { with: /[A-Za-z]+/ },
            length: { minimum: 2, maximum: 2 },
            presence: true
  validates :realm,
            presence: true
  validates :type,
            presence: true,
            inclusion: { in: %w( guild GUILD ) }


  def to_json
    if self.valid?
      case @type.downcase
        when "guild"
          JSON.parse(Net::HTTP.get_response(URI.parse(URI.encode("http://#{@locale.downcase}.battle.net/api/wow/guild/#{@realm.downcase}/#{@guild}?fields=members"))).body)
      end
    end
  end
end