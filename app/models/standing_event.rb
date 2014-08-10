class StandingEvent < Event
  belongs_to :standing, foreign_key: 'actor_id'
  belongs_to :raid

  after_create :apply_change
  before_update :revert_change
  after_update :apply_change
  after_destroy :revert_change

  validates :change,
            numericality: true
  validates :standing,
            presence: true
  validates :type,
            inclusion: [:attendance, :delinquent, :initial, :resume, :retirement]

  def self.gains
    where("#{table_name}.change > ?", 0)
  end

  def self.losses
    where("#{table_name}.change < ?", 0)
  end

  private
    def apply_change
      self.standing.update_attributes(points: self.standing.points + self.change)
    end
    def revert_change
      # Subtract what change was prior to current instance; useful for update
      self.change_was ?
        self.standing.update_attributes(points: self.standing.points - self.change_was) :
        self.standing.update_attributes(points: self.standing.points)
    end
end