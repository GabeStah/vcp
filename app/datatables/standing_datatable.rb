class StandingDatatable < AjaxDatatablesRails::Base
  include AjaxDatatablesRails::Extensions::WillPaginate

  def_delegators :@view,
                 :can?,
                 :current_user,
                 :edit_standing_path,
                 :l,
                 :link_to,
                 :link_to_if,
                 :format_points,
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
      character_class = standing.character.character_class.present? ? "<span class=#{standing.character.character_class.short_name}>#{standing.character.character_class.name}</span>" : nil
      guild = link_to_if(can?(:manage, standing.character.guild), standing.character.guild.name, standing.character.guild) if standing.character.guild
      realm = "#{standing.character.realm}-#{standing.character.region.upcase}"
      points = format_points(standing.points)
      if can?(:update, standing)
        retire = link_to("Retire", retire_standing_path(standing), method: :post, data: { confirm: "Retire #{standing.character.full_title} from Standings?" }) if can?(:update, standing)
        edit = link_to('Edit', edit_standing_path(standing))
        [
          name,
          character_class,
          guild,
          realm,
          points,
          "#{edit} #{retire}",
        ]
      else
        [
          name,
          character_class,
          guild,
          realm,
          points,
        ]
      end
    end
  end

  def get_raw_records
    Standing.eager_load(character: [:character_class, :guild]).where(active: true)
  end
end
