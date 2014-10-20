class RaceDatatable < AjaxDatatablesRails::Base
  include AjaxDatatablesRails::Extensions::WillPaginate

  def_delegators :@view,
                 :best_in_place,
                 :current_user,
                 :l,
                 :link_to

  def initialize(view)
    @view = view
    super(@view)
  end

  def sortable_columns
    @sortable_columns ||= ['races.name',
                           'races.blizzard_id',
                           'races.side']
  end

  def searchable_columns
    @searchable_columns ||= ['races.name',
                             'races.blizzard_id',
                             'races.side']
  end

  private

  def data
    records.map do |race|
      [
        best_in_place(race, :name, type: :input),
        best_in_place(race, :blizzard_id, type: :input),
        best_in_place(race, :side, type: :select, collection: WOW_FACTION_HASH)
      ]
    end
  end

  def get_raw_records
    Race.all
  end
end