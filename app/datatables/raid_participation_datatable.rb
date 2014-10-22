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
                           'participations.timestamp']
  end

  def searchable_columns
    @searchable_columns ||= ['characters.name',
                             'characters.realm',
                             'participations.online',
                             'participations.in_raid',
                             'participations.timestamp',
                             'participations.event']
  end

  private

  def data
    records.map do |participation|
      [
        link_to(participation.character.name, participation.character),
        "#{participation.character.realm}-#{participation.character.region.upcase}",
        best_in_place_if(can?(:manage, participation), participation, :online, type: :checkbox, path: participation_path(participation)),
        best_in_place_if(can?(:manage, participation), participation, :in_raid, type: :checkbox, path: participation_path(participation)),
        best_in_place_if(can?(:manage, participation), participation, :timestamp, type: :input, path: participation_path(participation), display_with: lambda { |p| l(p) }),
        participation.event(participation.previous(@raid.participations)),
        link_to_if(can?(:destroy, participation), 'Delete', participation, method: :delete, data: { confirm: "You sure?" })
      ]
    end
  end

  def get_raw_records
    @raid.participations.includes(:character)
  end
end