class RaidDatatable < AjaxDatatablesRails::Base
  include AjaxDatatablesRails::Extensions::WillPaginate

  def_delegators :@view, :l, :link_to

  def sortable_columns
    @sortable_columns ||= ['zones.name', 'raids.started_at', 'raids.ended_at']
  end

  def searchable_columns
    @searchable_columns ||= ['zones.name', 'raids.started_at', 'raids.ended_at']
  end

  private

  def data
    records.map do |raid|
      [
        link_to(raid.zone.name, raid),
        l(raid.started_at),
        l(raid.ended_at)
      ]
    end
  end

  def get_raw_records
    Raid.eager_load(:zone)
  end
end
