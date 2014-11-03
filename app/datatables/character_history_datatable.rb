class CharacterHistoryDatatable < AjaxDatatablesRails::Base
  include AjaxDatatablesRails::Extensions::WillPaginate

  attr_accessor :type

  def_delegators :@view,
                 :current_user,
                 :distance_of_time_in_words,
                 :format_points,
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
      standing_events = raid.standing_events.where(standing: @standing)

      absent = standing_events.absent?
      attended = standing_events.attended?(raid: raid)
      sat = standing_events.sat?
      tardy = standing_events.tardy?
      if tardy || absent
        participations = Participation.where(character: @standing.character, raid: raid).order(:timestamp)
        # Create StandingCalculation instance WITHOUT processing
        standing_calculation = StandingCalculation.new(character: @standing.character, participations: participations, raid: raid, skip_process: true)
        first_online = standing_calculation.first_time(event: :online)
        if first_online.nil?
          absent = "<span class='character-history-tooltip' data-tip='<span class=red>Not online</span>'>Absent</span>"
        else
          time_diff = distance_of_time_in_words(raid.started_at, first_online)
          if tardy
            tardy = "<span class='character-history-tooltip' data-tip='<span class=green>#{time_diff} late</span><br/>(#{first_online})'>Tardy</span>"
          elsif absent
            absent = "<span class='character-history-tooltip' data-tip='<span class=green>#{time_diff} late</span><br/>(#{first_online})'>Absent</span>"
          end
        end
      end

      unexcused_absence = standing_events.unexcused_absence?
      events_output = "#{absent && unexcused_absence ? 'Unexcused Absence' : absent ? absent : nil} #{attended ? 'Attended' : nil} #{sat ? 'Sat' : nil} #{tardy ? tardy : nil}"

      points = "<span class='character-history-tooltip' data-tip='#{standing_events_summary(standing_events)}'>#{format_points(standing_events.sum(:change))}</span>"
      # Sums all earned points from raids up to and including this raid
      # Also adds non-raid point totals occuring prior to this raid date (initial/resume/retire/etc)
      total_points = StandingEvent.where(standing: @standing).where.any_of({raid: Raid.where('started_at <= ?', raid.started_at)}, ['created_at <= ?', raid.started_at]).sum(:change)

      # Return table
      [
        link_to(raid.zone.name, raid),
        link_to(l(raid.started_at.in_time_zone), raid),
        events_output,
        points,
        format_points(total_points),
      ]
    end
  end

  def make_table(events)
    events.collect do |event|
      gain_loss = event.change >= 0 ? 'Gain' : 'Loss'
      if event.parent && event.parent.standing
        from = "<span class=#{event.parent.standing.character.character_class ? event.parent.standing.character.character_class.short_name : nil}>" + "#{event.parent.standing.character.name}</span>"
      else
        from = "<i>self</i>"
      end
      "<tr><td><span class=#{event.change > 0 ? 'green' : 'red'}>#{format_points(event.change)}</span></td><td>#{event.type.camelize} #{gain_loss}</td><td>#{from}</td></tr>"
    end.join
  end

  def standing_events_summary(events)
    "<table class=character-history-tooltip-table>
      <thead>
        <th>Points</th>
        <th>Type</th>
        <th>Source</th>
      </thead>
      <tbody>
        #{make_table(events)}
      </tbody>
    </table>"
  end

  def get_raw_records
    if @standing
      Raid.joins(:standing_events).where('events.actor_id = ?', @standing).
        eager_load(:participations, :zone)
    end
  end
end
