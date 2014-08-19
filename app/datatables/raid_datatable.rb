class RaidDatatable < AjaxDatatablesRails::Base
  include AjaxDatatablesRails::Extensions::WillPaginate

  def_delegators :@view, :l

  def sortable_columns
    @sortable_columns ||= ['zones.name', 'raids.started_at', 'raids.ended_at']
  end

  def searchable_columns
    @searchable_columns ||= ['zones.name', 'raids.started_at', 'raids.ended_at']
  end

  private

  def data
    records.map do |record|
      [
        record.zone.name,
        l(record.started_at),
        l(record.ended_at)
      ]
    end
  end

  def get_raw_records
    Raid.includes(:zone)
  end
end
