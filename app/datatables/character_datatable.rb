class CharacterDatatable < AjaxDatatablesRails::Base
  include AjaxDatatablesRails::Extensions::WillPaginate

  attr_accessor :type

  def_delegators :@view,
                 :can?,
                 :current_user,
                 :fa_icon,
                 :l,
                 :link_to,
                 :number_with_delimiter,
                 :sync_character_path,
                 :unclaim_character_path

  def initialize(view, options = {})
    @view = view
    @options = options
    @type = options[:type]
    @user = options[:user]
    super(@view, @options)
  end

  def sortable_columns
    @sortable_columns ||= ['characters.name',
                           'character_classes.name',
                           'guilds.name',
                           'characters.realm',
                           'characters.raids_count',
                           'characters.achievement_points',
                           'characters.created_at']
  end

  def searchable_columns
    @searchable_columns ||= ['characters.name',
                             'character_classes.name',
                             'guilds.name',
                             'characters.realm',
                             'characters.raids_count',
                             'characters.achievement_points',
                             'characters.created_at']
  end

  private

  def data
    if current_user && type.to_sym == :claimed
      records.map do |character|
        [
          link_to(character.name, character),
          character.character_class ?
            "<span class=#{character.character_class.short_name}>#{character.character_class.name}</span>" : nil,
          character.guild.present? ?
            link_to(character.guild.name, character.guild) : nil,
          "#{character.realm}-#{character.region.upcase}",
          character.raids_count > 0 ? character.raids_count : nil,
          number_with_delimiter(character.achievement_points),
          l(character.created_at.in_time_zone, format: :short),
          can?(:update, character) ?
            link_to(fa_icon("refresh"), sync_character_path(character), method: :post, title: "Refresh from Battle.net", data: {toggle: 'tooltip'}) : nil,
        ]
      end
    else
      records.map do |character|
        [
          link_to(character.name, character),
          character.character_class ?
            "<span class=#{character.character_class.short_name}>#{character.character_class.name}</span>" : nil,
          character.guild.present? ?
            link_to(character.guild.name, character.guild) : nil,
          "#{character.realm}-#{character.region.upcase}",
          character.raids_count > 0 ? character.raids_count : nil,
          number_with_delimiter(character.achievement_points),
          l(character.created_at.in_time_zone, format: :short),
        ]
      end
    end
  end

  def get_raw_records
    case type.to_sym
      when :claimed
        return Character.claimed(@user).eager_load(:character_class, :guild, :raids, :user) if @user
      when :unclaimed
        return Character.unclaimed(@user).eager_load(:character_class, :guild, :raids, :user) if @user
      when :all
        return Character.where(verified: true).eager_load(:character_class, :guild, :raids, :user)
    end
    Character.none
  end
end
