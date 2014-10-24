class CharacterClassDatatable < AjaxDatatablesRails::Base
  include AjaxDatatablesRails::Extensions::WillPaginate

  def_delegators :@view,
                 :best_in_place,
                 :class_path,
                 :current_user,
                 :l,
                 :link_to

  def initialize(view)
    @view = view
    super(@view)
  end

  def sortable_columns
    @sortable_columns ||= ['character_classes.name',
                           'character_classes.blizzard_id']
  end

  def searchable_columns
    @searchable_columns ||= ['character_classes.name',
                             'character_classes.blizzard_id']
  end

  private

  def data
    records.map do |character_class|
      [
        best_in_place(character_class, :name, type: :input, path: class_path(character_class)),
        best_in_place(character_class, :blizzard_id, type: :input, path: class_path(character_class)),
        link_to('Delete', class_path(character_class), method: :delete, data: { confirm: "Confirm deletion of #{character_class.name}?"})
      ]
    end
  end

  def get_raw_records
    CharacterClass.all
  end
end