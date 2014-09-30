class Standing < ActiveRecord::Base
  belongs_to :character
  has_many :standing_events, foreign_key: :actor_id

  attr_accessor :distribute

  after_create :initial_standing_event

  validates :character,
            presence: true,
            uniqueness: true
  validates :points,
            numericality: true

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

  def gains(type)
    case type.to_sym
      when :delinquency
        #self.standing_events.sum(:change)
        standing_events.gains.where(type: :delinquent).sum(:change)
      when :infraction
        standing_events.gains.sum(:change)
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
      # 2. StandingEvent for retirement
      StandingEvent.create(change: 0,
                           standing: self,
                           type: :retirement)
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

  # Total points for all active Standings
  def self.total_points
    Standing.where(active: true).sum(:points).round(5)
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
