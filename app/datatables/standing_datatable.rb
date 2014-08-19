class StandingDatatable < AjaxDatatablesRails::Base
  include AjaxDatatablesRails::Extensions::WillPaginate

  def_delegators :@view,
                 :current_user,
                 :l,
                 :link_to

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

#   <td><%= link_to standing.character.name, standing.character %></td>
#   <td><%= standing.character.character_class.name if standing.character.character_class %></td>
#   <% if current_user && current_user.admin? %>
#     <td><%= link_to standing.character.guild.name, standing.character.guild if standing.character.guild %></td>
#   <% else %>
#     <td><%= standing.character.guild.name if standing.character.guild %></td>
#   <% end %>
#   <td><%= "#{standing.character.realm}-#{standing.character.region.upcase}" %></td>
#   <td><%= standing.points || 0 %></td>
#   <% if current_user && current_user.admin? %>
#     <td><%= link_to "Delete", standing, method: :delete, data: { confirm: "Delete standing for #{standing.character.name}?" } %></td>
#   <% end %>
# <% if user_owns_character?(standing.character) || admin_signed_in? %>
#     <td>
# <%= render 'characters/character_edit', character: standing.character %>
#     </td>
#   <% end %>

  def data
    records.map do |standing|
      name = link_to(standing.character.name, standing.character)
      character_class = standing.character.character_class.present? ? standing.character.character_class.name : nil
      guild = standing.character.guild.name
      guild = link_to(standing.character.guild.name, standing.character.guild) if @current_user && @current_user.admin? && standing.character.guild
      realm = "#{standing.character.realm}-#{standing.character.region.upcase}"
      points = standing.points || 0
      retire = link_to("Retire", standing, method: :delete, data: { confirm: "Retire #{standing.character.name} from Standings?" }) if @current_user && @current_user.admin?
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
