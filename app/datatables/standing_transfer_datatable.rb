class StandingTransferDatatable < AjaxDatatablesRails::Base
  include AjaxDatatablesRails::Extensions::WillPaginate

  def_delegators :@view,
                 :current_user,
                 :l,
                 :link_to,
                 :standing,
                 :transfer_standing_path

  def initialize(view, standing)
    @view = view
    @current_user = current_user
    @standing = standing
    super(@view)
  end

  def sortable_columns
    @sortable_columns ||= ['characters.name',
                           'character_classes.name',
                           'characters.realm',
                           'characters.created_at']
  end

  def searchable_columns
    @searchable_columns ||= ['characters.name',
                             'character_classes.name',
                             'characters.realm',
                             'characters.created_at']
  end

  private

  def data
    records.map do |character|
      class_name = "<span class=#{character.character_class.short_name}>#{character.character_class.name}</span>"
      [
        link_to(character.name, character),
        character.character_class.present? ? class_name : nil,
        "#{character.realm}-#{character.region.upcase}",
        l(character.created_at.in_time_zone, format: :short),
        link_to('Transfer', transfer_standing_path(@standing, character: character), method: :post, data: { confirm: "Transfer Standing from #{@standing.character.full_title} to #{character.full_title}?", toggle: 'tooltip' }, title: "Transfer all Standing associations from #{@standing.character.full_title} to #{character.full_title}")
      ]
    end
  end

  def get_raw_records
    Character.where(verified: true).
      eager_load(:character_class)
  end
end