class Standing < ActiveRecord::Base
  belongs_to :character
  has_many :standing_events,     foreign_key: :actor_id
  has_one :standing_statistic, foreign_key: :record_id

  attr_accessor :distribute

  after_create :initial_standing_event

  validates :character,
            presence: true,
            uniqueness: true
  validates :points,
            numericality: true
  validates :seeded,
            inclusion: [true, false]

  def self.calculate_starting_points(args = {})
    seed = args[:seed] || 1
    players = args[:players] || 10
    increment = args[:increment] || 0.1
    if (players % 2) == 0 # even
      (increment * players / 2 - increment / 2 - (seed - 1) * increment).round(4)
    else # odd
      (increment * (players - 1) / 2 - (seed - 1) * increment).round(4)
    end
  end

  def self.created_before(time)
    where("#{table_name}.created_at <= ?", time)
  end

  # Get dates of recent activity
  def active_between
    if self.active
      # If active, end date is now and start date is recent :resume or :initial
      end_date = Time.zone.now
      start_date = standing_events.where.any_of({type: :initial}, {type: :resume}).order(:created_at).last.created_at
      return start_date, end_date
    else
      # If inactive, end date is recent :retire and start date is prior :resume or :initial
      end_date = standing_events.where(type: :retire).order(:created_at).last.created_at
      start_date = standing_events.where("#{StandingEvent.table_name}.created-at < ?", end_date).any_of({type: :initial}, {type: :resume}).order(:created_at).last.created_at
      return start_date, end_date
    end
  end

  def gains(type)
    case type.to_sym
      when :delinquency
        #self.standing_events.sum(:change)
        standing_events.gains.where(type: :delinquent).sum(:change)
      when :infraction
        standing_events.gains.where(type: :infraction).sum(:change)
      when :initial
        standing_events.gains.where(type: :initial).sum(:change)
      when :resume
        standing_events.gains.where(type: :resume).sum(:change)
      when :retire
        standing_events.gains.where(type: :retire).sum(:change)
      when :sitting
        standing_events.where(type: :attendance).where("#{StandingEvent.table_name}.change = ?", Settings.standing.attendance_gain).sum(:change)
      else # :total
        standing_events.gains.sum(:change)
    end
  end

  def losses(type)
    case type.to_sym
      when :absence
        standing_events.losses.where(type: :delinquent).where("#{StandingEvent.table_name}.change = ?", Settings.standing.delinquent_loss).sum(:change)
      when :attendance
        standing_events.losses.where(type: :attendance).sum(:change)
      when :delinquency
        standing_events.losses.where(type: :delinquent).sum(:change)
      when :infraction
        standing_events.losses.where(type: :infraction).sum(:change)
      when :initial
        standing_events.losses.where(type: :initial).sum(:change)
      when :resume
        standing_events.losses.where(type: :resume).sum(:change)
      when :retire
        standing_events.losses.where(type: :retire).sum(:change)
      else # :total
        standing_events.losses.sum(:change)
    end
  end

  # Resume a previously inactive record
  def resume
    # Ensure already inactive
    unless self.active
      # Set active true
      update(active: true)
      # 2. StandingEvent for resume
      StandingEvent.create(change: 0,
                           standing: self,
                           type: :resume)
      return true
    end
    false
  end

  # Retire standing record
  def retire
    unless !self.active
      # 1. Set active = false
      update(active: false)
      # 2. StandingEvent for retire
      StandingEvent.create(change: 0,
                           standing: self,
                           type: :retire)
      return true
    end
    false
  end

  # Transfer existing Standing records to new Character
  def transfer(character)
    return nil if character.nil?
    character = Character.find(character) unless character.is_a? Character
    # Make sure new Character doesn't have a Standing
    return nil if Standing.find_by(character: character).present?
    # Transfer record
    result = update_attributes(character: character)
    true
  end

  def self.reset_seeded
    update_all(seeded: false, active: true)
  end

  # Total points for all active Standings
  def self.total_points
    where(active: true).sum(:points).round(5)
  end

  def update_statistics
    StandingStatistic.create(standing: self) if self.standing_statistic.nil?
    statistic = StandingStatistic.where(standing: self).first
    statistic.calculate_all if statistic
  end

  private

  def initial_standing_event
    StandingEvent.create(change: points,
                         created: true,
                         distribute: distribute,
                         standing: self,
                         type: :initial)
  end
end
