class StandingDatatable < AjaxDatatablesRails::Base
  include AjaxDatatablesRails::Extensions::WillPaginate

  def_delegators :@view,
                 :current_user,
                 :l,
                 :link_to,
                 :retire_standing_path

  def initialize(view, options = {})
    @view = view
    @options = options
    @type = options[:type]
    @current_user = current_user
    super(@view, @options)
  end

  def sortable_columns
    @sortable_columns ||= [
      'characters.name',
      'character_classes.name',
      'guilds.name',
      'characters.realm',
      'standings.points',
    ]
  end

  def searchable_columns
    @searchable_columns ||= [
      'characters.name',
      'character_classes.name',
      'guilds.name',
      'characters.realm',
      'standings.points',
    ]
  end

  private

  def data
    records.map do |standing|
      name = link_to(standing.character.name, standing.character)
      character_class = standing.character.character_class.present? ? standing.character.character_class.name : nil
      guild = standing.character.guild.name
      guild = link_to(standing.character.guild.name, standing.character.guild) if @current_user && @current_user.admin? && standing.character.guild
      realm = "#{standing.character.realm}-#{standing.character.region.upcase}"
      points = standing.points || 0
      retire = link_to("Retire", retire_standing_path(standing), method: :post, data: { confirm: "Retire #{standing.character.full_title} from Standings?" }) if @current_user && @current_user.admin?
      [
        name,
        character_class,
        guild,
        realm,
        points,
        retire,
      ]
    end
  end

  def get_raw_records
    Standing.eager_load(character: [:character_class, :guild]).where(active: true)
  end
end
