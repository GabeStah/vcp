class CharacterDatatable < AjaxDatatablesRails::Base
  include AjaxDatatablesRails::Extensions::WillPaginate

  attr_accessor :type

  def_delegators :@view,
                 :can?,
                 :current_user,
                 :l,
                 :link_to,
                 :sync_character_path,
                 :unclaim_character_path

  def initialize(view, options = {})
    @view = view
    @options = options
    @type = options[:type]
    @current_user = current_user
    super(@view, @options)
  end

  def sortable_columns
    @sortable_columns ||= ['characters.name',
                           'character_classes.name',
                           'guilds.name',
                           'characters.realm',
                           'raids.id',
                           'characters.achievement_points',
                           'characters.created_at']
  end

  def searchable_columns
    @searchable_columns ||= ['characters.name',
                             'character_classes.name',
                             'guilds.name',
                             'characters.realm',
                             'raids.id',
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
          character.raids.distinct.size > 0 ?
            character.raids.distinct.size : nil,
          character.achievement_points,
          l(character.created_at.in_time_zone, format: :short),
          can?(:update, character) ?
            "#{link_to('Sync', sync_character_path(character), method: :post)}" : nil,
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
          character.raids.distinct.size > 0 ?
            character.raids.distinct.size : nil,
          character.achievement_points,
          l(character.created_at.in_time_zone, format: :short),
        ]
      end
    end
  end

  def get_raw_records
    case type.to_sym
      when :claimed
        if current_user
          Character.claimed(current_user).
            eager_load(:character_class, :guild, :raids, :user)
        end
      when :unclaimed
        if current_user
          Character.unclaimed(current_user).
            eager_load(:character_class, :guild, :raids, :user)
        end
      when :all
        Character.where(verified: true).
          eager_load(:character_class, :guild, :raids, :user)
    end
  end
end
