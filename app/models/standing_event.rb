class StandingEvent < Event
  belongs_to :standing, foreign_key: 'actor_id'
  belongs_to :raid

  # TODO: Integrate with participation model

  validates :standing,
            presence: true
end