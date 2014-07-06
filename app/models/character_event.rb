class CharacterEvent < Event
  belongs_to :character, foreign_key: 'actor_id'

  validates :character,
            presence: true
end