class CharacterHistoryDatatable < AjaxDatatablesRails::Base
  include AjaxDatatablesRails::Extensions::WillPaginate

  attr_accessor :type

  def_delegators :@view,
                 :current_user,
                 :l,
                 :link_to

  def initialize(view, options = {})
    @view = view
    @options = options
    @character = options[:character]
    @standing = options[:standing]
    @current_user = current_user
    super(@view, @options)
  end

  def sortable_columns
    @sortable_columns ||= ['zones.name',
                           'raids.started_at',
                           'events.type',
                           'events.change']
  end

  def searchable_columns
    @searchable_columns ||= ['zones.name',
                             'raids.started_at',
                             'events.type',
                             'events.change']
  end

  private

  def data
    records.map do |raid|
      # Get standing_events list
      absent = raid.standing_events.where(standing: @standing).absent?
      attended = raid.standing_events.where(standing: @standing).attended?(raid: raid)
      sat = raid.standing_events.where(standing: @standing).sat?
      tardy = raid.standing_events.where(standing: @standing).tardy?
      unexcused_absence = raid.standing_events.where(standing: @standing).unexcused_absence?
      events_output = "#{absent && unexcused_absence ? 'Unexcused Absence' : absent ? 'Absent' : nil} #{attended ? 'Attended' : nil} #{sat ? 'Sat' : nil} #{tardy ? 'Tardy' : nil}"
      # Sums all earned points from raids up to and including this raid
      # Also adds non-raid point totals occuring prior to this raid date (initial/resume/retire/etc)
      total_points = StandingEvent.where(standing: @standing).where.any_of({raid: Raid.where('started_at <= ?', raid.started_at)}, ['created_at <= ?', raid.started_at]).sum(:change)

      # Return table
      [
        link_to(raid.zone.name, raid),
        link_to(l(raid.started_at), raid),
        events_output,
        raid.standing_events.where(standing: @standing).sum(:change),
        total_points,
        link_to('more', '#'),
      ]
    end
  end

  def get_raw_records
     Raid.joins(:standing_events).where('events.actor_id = ?', @standing).
       eager_load(:participations, :zone)
  end
end
