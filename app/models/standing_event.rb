class StandingEvent < Event
  belongs_to :standing, foreign_key: 'actor_id'

  attr_accessor :change,
                :previous_points,
                :standing,
                :type # attendance, deliquent, retirement, initial

  validates :standing,
            presence: true
end