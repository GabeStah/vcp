class RaidParticipationDatatable < AjaxDatatablesRails::Base
  include AjaxDatatablesRails::Extensions::WillPaginate

  def_delegators :@view,
                 :best_in_place,
                 :best_in_place_if,
                 :can?,
                 :current_user,
                 :l,
                 :link_to,
                 :link_to_if,
                 :participation_path

  def initialize(view, options = {})
    @view = view
    @options = options
    @raid = options[:raid]
    super(@view)
  end

  def sortable_columns
    @sortable_columns ||= ['characters.name',
                           'characters.realm',
                           'participations.online',
                           'participations.in_raid',
                           'participations.unexcused',
                           'participations.timestamp']
  end

  def searchable_columns
    @searchable_columns ||= ['characters.name',
                             'characters.realm',
                             'participations.online',
                             'participations.in_raid',
                             'participations.unexcused',
                             'participations.timestamp',
                             'participations.event']
  end

  private

  def data
    if can? :manage, Participation
      records.map do |participation|
        search_icon = "<span class='glyphicon glyphicon-search raid-participation-event-tooltip' data-tip='#{participation.event(participation.previous(@raid.participations))}'></span>"
        [
          link_to(participation.character.name, participation.character),
          "#{participation.character.realm}-#{participation.character.region.upcase}",
          best_in_place_if(can?(:manage, participation), participation, :online, as: :checkbox, url: participation_path(participation)),
          best_in_place_if(can?(:manage, participation), participation, :in_raid, as: :checkbox, url: participation_path(participation)),
          best_in_place_if(can?(:manage, participation), participation, :unexcused, as: :checkbox, url: participation_path(participation)),
          best_in_place_if(can?(:manage, participation), participation, :timestamp, as: :input, url: participation_path(participation), display_with: lambda { |p| l(p) }),
          search_icon,
          link_to_if(can?(:destroy, participation), 'Delete', participation, method: :delete, data: { confirm: "You sure?" })
        ]
      end
    else
      records.map do |participation|

        search_icon = "<span class='glyphicon glyphicon-search raid-participation-event-tooltip' data-tip='#{participation.event(participation.previous(@raid.participations))}'></span>"
        [
          link_to(participation.character.name, participation.character),
          "#{participation.character.realm}-#{participation.character.region.upcase}",
          "<span class='glyphicon glyphicon-#{participation.online ? 'ok green' : 'remove red'}'></span>",
          "<span class='glyphicon glyphicon-#{participation.in_raid ? 'ok green' : 'remove red'}'></span>",
          "<span class='glyphicon glyphicon-#{participation.unexcused ? 'ok green' : 'remove red'}'></span>",
          l(participation.timestamp),
          search_icon,
          link_to_if(can?(:destroy, participation), 'Delete', participation, method: :delete, data: { confirm: "You sure?" })
        ]
      end
    end
  end

  def get_raw_records
    @raid.participations.includes(:character)
  end
end