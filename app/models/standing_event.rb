class StandingEvent < Event
  belongs_to :standing, foreign_key: 'actor_id'
  belongs_to :raid

  after_create :apply_change
  before_update :revert_change
  after_update :apply_change
  after_destroy :revert_change

  validates :change,
            numericality: true
  validates :raid,
            presence: true
  validates :standing,
            presence: true
  validates :type,
            inclusion: [:attendance, :delinquent, :initial, :retirement]

  private
    def apply_change
      self.standing.update_attributes(points: self.standing.points + self.change)
    end
    def revert_change
      # Subtract what change was prior to current instance; useful for update
      self.standing.update_attributes(points: self.standing.points - self.change_was)
    end
end