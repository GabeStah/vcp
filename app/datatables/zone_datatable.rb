class ZoneDatatable < AjaxDatatablesRails::Base
  include AjaxDatatablesRails::Extensions::WillPaginate

  def_delegators :@view,
                 :best_in_place,
                 :can?,
                 :current_user,
                 :l,
                 :link_to,
                 :zone_path

  def initialize(view)
    @view = view
    super(@view)
  end

  def sortable_columns
    @sortable_columns ||= ['zones.name',
                           'zones.zone_type',
                           'zones.level',
                           'zones.blizzard_id']
  end

  def searchable_columns
    @searchable_columns ||= ['zones.name',
                             'zones.zone_type',
                             'zones.level',
                             'zones.blizzard_id']
  end

  private

  def data
    records.map do |zone|
      [
        best_in_place(zone, :name, type: :input),
        best_in_place(zone, :zone_type, type: :select, collection: WOW_ZONE_TYPE_HASH),
        best_in_place(zone, :level, type: :input),
        best_in_place(zone, :blizzard_id, type: :input),
        can?(:destroy, zone) ? link_to('Delete', zone_path(zone), method: :delete, data: { confirm: "Delete #{zone.name}?" }) : nil
      ]
    end
  end

  def get_raw_records
    Zone.all
  end
end