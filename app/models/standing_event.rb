class StandingEvent < Event
  has_many :children, class_name: "StandingEvent", foreign_key: "parent_id", dependent: :destroy
  belongs_to :parent, class_name: "StandingEvent"
  belongs_to :standing, foreign_key: 'actor_id'
  belongs_to :raid

  after_create :apply_change
  after_create :process_children
  before_update :revert_change
  after_update :apply_change
  after_update :process_children_updates
  after_destroy :revert_change

  attr_accessor :created, :distribute

  validates :change,
            numericality: true
  validates :standing,
            presence: true
  validates :type,
            inclusion: %w(adjustment attendance delinquent infraction initial resume retirement)

  def self.dominant
    where.any_of(no_parent.merge(no_children), has_children)
  end

  def self.gains
    where("#{table_name}.change > ?", 0)
  end

  def self.has_children
    includes(:children).where.not(children_events: { id: nil })
  end

  def self.losses
    where("#{table_name}.change < ?", 0)
  end

  def self.no_children
    includes(:children).where(children_events: { id: nil })
  end

  def self.no_parent
    where(parent: nil)
  end

  def type=(new_type)
    super new_type.to_s
  end

  private

  def apply_change
    # If newly created record and :initial, don't change
    unless created && type.to_sym == :initial
      self.standing.update(points: self.standing.points + self.change)
    end
  end

  def process_children
    if [:adjustment, :infraction].include? self.type.to_sym
      # not zero value
      if self.change != 0
        # Find all standing where active = true and created_at was prior to raid.started_at
        standings = Standing.where(active: true)
        # If only one standing, originator is only target so no change
        if standings.size > 1
          # Loop through standings
          standings.each do |standing|
            # Make sure standing_event originator does not equal current updated standing character
            if self.standing.id != standing.id && self.parent.nil?
              # Get divided value
              value = self.change.to_f / (standings.size - 1)
              # Inverse value
              value *= -1
              # Create a StandingEvent with distributed value
              StandingEvent.create(change: value,
                                   parent: self,
                                   standing: standing,
                                   type: self.type.to_sym)
            end
          end
        end
      end
    elsif self.type.to_sym == :delinquent
      # ensure loss
      if self.change < 0
        # Find all standing where active = true
        standings = Standing.where(active: true)
        # If only one standing, originator is only target so no change
        if standings.size > 1
          # Loop through standings
          standings.each do |standing|
            # Make sure standing_event originator does not equal current updated standing character
            unless self.standing.id == standing.id
              # Get divided value
              value = self.change.to_f / (standings.size - 1)
              # Double delinquent value gain for all others to balance out
              value *= 2
              # Inverse value
              value *= -1
              # Create a StandingEvent with distributed value
              StandingEvent.create(change: value,
                                   parent: self,
                                   raid: self.raid,
                                   standing: standing,
                                   type: self.type.to_sym)
            end
          end
        end
      end
    elsif self.type.to_sym == :initial
      # If distribute flag is true and change not zero, then distribute appropriately
      if self.distribute && self.change != 0
        # Find all standing where active = true
        standings = Standing.where(active: true)
        # If only one standing, originator is only target so no change
        if standings.size > 1
          # Loop through standings
          standings.each do |standing|
            # Make sure standing_event originator does not equal current updated standing character
            unless self.standing.id == standing.id
              # Get divided value
              value = self.change.to_f / (standings.size - 1)
              # Inverse value
              value *= -1
              # Create a StandingEvent with distributed value
              StandingEvent.create(change: value,
                                   parent: self,
                                   standing: standing,
                                   type: self.type.to_sym)
            end
          end
        end
      end
    elsif self.type.to_sym == :resume
      if self.change == 0 && self.standing.points != 0
        # Reverse points distribution among remaining Standings
        # Assign standings set
        standings = Standing.where(active: true)
        if standings.size > 1
          # Loop through active standings
          standings.each do |standing|
            # Ensure standing not equal to self.standing
            unless standing.id == self.standing.id
              # Get divided value
              # Remove one record to account for self
              value = self.standing.points.to_f / (standings.size - 1)
              # Inverse value
              value *= -1
              # Create a StandingEvent with distributed value
              StandingEvent.create(change: value,
                                   parent: self,
                                   standing: standing,
                                   type: self.type.to_sym)
            end
          end
        end
      end
    elsif self.type.to_sym == :retirement
      if self.change == 0 && self.standing.points != 0
        # Distribute points among remaining Standing
        standings = Standing.where(active: true)

        # Loop through active standings
        standings.each do |standing|
          # Get divided value
          value = self.standing.points.to_f / standings.size
          # Create a StandingEvent with distributed value
          standing_event = StandingEvent.create(change: value,
                                                parent: self,
                                                standing: standing,
                                                type: self.type.to_sym)
        end
      end
    end
  end

  def process_children_updates
    if self.children.size > 0
      if [:adjustment, :delinquent, :infraction, :initial].include? self.type.to_sym
        # Get divided value
        value = self.change.to_f / self.children.size
        # Inverse value
        value *= -1
        self.children.each do |standing_event|
          standing_event.update(change: value)
        end
      end
    end
  end

  def revert_change
    # if self.change_was
    #   self.standing.update(points: self.standing.points - self.change_was)
    # else
    #   self.standing.update(points: self.standing.points)
    # end
    # Subtract what change was prior to current instance; useful for update
    self.change_was ?
      self.standing.update(points: self.standing.points - self.change_was) :
      self.standing.update(points: self.standing.points)
  end
end