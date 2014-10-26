class UserDatatable < AjaxDatatablesRails::Base
  include AjaxDatatablesRails::Extensions::WillPaginate

  def_delegators :@view,
                 :can?,
                 :current_user,
                 :l,
                 :link_to,
                 :standing,
                 :transfer_standing_path

  def initialize(view)
    @view = view
    super(@view)
  end

  def sortable_columns
    @sortable_columns ||= ['users.name',
                           'users.characters_verified_count',
                           'users.characters_count',
                           'users.created_at']
  end

  def searchable_columns
    @searchable_columns ||= ['users.name',
                             'users.characters_verified_count',
                             'users.characters_count',
                             'users.created_at']
  end

  private

  def data
    records.map do |user|
      [
        link_to(user.name, user),
        user.characters_verified_count > 0 ? user.characters_verified_count : nil,
        user.characters_count > 0 ? user.characters_count : nil,
        l(user.created_at.in_time_zone, format: :short),
        can?(:destroy, user) && current_user != user ? link_to("delete", user, method: :delete, data: { confirm: "Are you sure you wish to delete #{user.name} [#{user.id}]?" }) : nil
      ]
    end
  end

  def get_raw_records
    User.all.eager_load(:characters)
  end
end