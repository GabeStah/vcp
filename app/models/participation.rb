class Participation < ActiveRecord::Base
  belongs_to :character
  belongs_to :raid

  # character
  validates :character,
            uniqueness: {
                message: '+ Raid + Timestamp already exists.',
                scope: [:raid, :timestamp],
            },
            presence: true
  # in_raid
  validates :in_raid,
            inclusion: [true, false]
  # online
  validates :online,
            inclusion: [true, false]
  # raid
  validates :raid,
            presence: true
  # timestamp
  validate :timestamp_is_valid_datetime

  private

  def timestamp_is_valid_datetime
    errors.add(:timestamp, 'must be a valid datetime') if ((DateTime.parse(timestamp.to_s) rescue ArgumentError) == ArgumentError)
  end
end