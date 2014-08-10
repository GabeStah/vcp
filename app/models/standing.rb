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

  # Retire standing record
  def retire
    # 1. Set active = false
    update_attributes(active: false)
    current_points = self.points
    # 2. StandingEvent for retirement reverse
    # No point change, just create retirement record
    standing_event = StandingEvent.create(change: 0,
                                          standing: self,
                                          type: :retirement)

    if self.points != 0
      # 3. Distribute points among remaining Standing
      standings = Standing.where(active: true)

      # Loop through active standings
      standings.each do |standing|
        # Get divided value
        value = current_points.to_f / standings.size
        # Create a StandingEvent with distributed value
        StandingEvent.create(change: value,
                             standing: standing,
                             type: :retirement)
      end
    end
  end

  def self.total_points
    Standing.where(active: true).sum(:points)
  end

end
