class Standing < ActiveRecord::Base
  belongs_to :character
  has_many :standing_events

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
    end
  end

  # Retire standing record
  def retire
    # 1. Set active = false
    update(active: false)
    # 2. StandingEvent for retirement
    StandingEvent.create(change: 0,
                         standing: self,
                         type: :retirement)
  end

  def self.total_points
    Standing.where(active: true).sum(:points)
  end

end
