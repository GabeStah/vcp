class StandingStatistic < Statistic
  belongs_to :standing, foreign_key: 'record_id'

  validates :standing,
            presence: true

  def calculate_all
    if self.standing
      active_start_date, active_end_date = self.standing.active_between
      # Raids during activity
      active_raid_count = Raid.between(after: active_start_date, before: active_end_date).size

      # Get standing_events list
      standing_events = self.standing.standing_events

      # Sum of total raid time while sitting
      # standing_events.between(type: :sat).collect { |e| e.raid.ended_at - e.raid.started_at }.inject(:+)

      update_attributes(
        gains_delinquency:  self.standing.gains(:delinquency),
        gains_infraction:   self.standing.gains(:infraction),
        gains_initial:      self.standing.gains(:initial),
        gains_resume:       self.standing.gains(:resume),
        gains_retire:       self.standing.gains(:retire),
        gains_sitting:      self.standing.gains(:sitting),
        gains_total:        self.standing.gains(:total),

        losses_attendance:  self.standing.losses(:attendance),
        losses_absence:     self.standing.losses(:absence),
        losses_delinquency: self.standing.losses(:delinquency),
        losses_infraction:  self.standing.losses(:infraction),
        losses_initial:     self.standing.losses(:initial),
        losses_resume:      self.standing.losses(:resume),
        losses_retire:      self.standing.losses(:retire),
        losses_total:       self.standing.losses(:total),

        raids_absent_three_month: standing_events.between(type: :absent, after: 3.months.ago).size,
        raids_absent_year: standing_events.between(type: :absent, after: 1.year.ago).size,
        raids_absent_total: standing_events.between(type: :absent).size,

        raids_attended_three_month: standing_events.between(type: :attended, after: 3.months.ago).size,
        raids_attended_year: standing_events.between(type: :attended, after: 1.year.ago).size,
        raids_attended_total: standing_events.between(type: :attended).size,

        raids_delinquent_three_month: standing_events.between(type: :delinquent, after: 3.months.ago).size,
        raids_delinquent_year: standing_events.between(type: :delinquent, after: 1.year.ago).size,
        raids_delinquent_total: standing_events.between(type: :delinquent).size,

        raids_sat_three_month: standing_events.between(type: :sat, after: 3.months.ago).size,
        raids_sat_year: standing_events.between(type: :sat, after: 1.year.ago).size,
        raids_sat_total: standing_events.between(type: :sat).size,
      )

      if active_raid_count > 0
        update_attributes(
          raids_absent_percent: standing_events.between(type: :absent, after: active_start_date, before: active_end_date).size / active_raid_count.to_f * 100,
          raids_attended_percent: standing_events.between(type: :attended, after: active_start_date, before: active_end_date).size / active_raid_count.to_f * 100,
          raids_delinquent_percent: standing_events.between(type: :delinquent, after: active_start_date, before: active_end_date).size / active_raid_count.to_f * 100,
          raids_sat_percent: standing_events.between(type: :sat, after: active_start_date, before: active_end_date).size / active_raid_count.to_f * 100
        )
      end
    end
  end

  def key(*args)
    all = args.map { |arg| arg.to_s.downcase }
    all.join('_')
  end

  def type=(new_type)
    super new_type.to_s
  end

  private
end