class Raid < ActiveRecord::Base
  belongs_to :zone
  has_many :participations
  # Destroy participations associated with Raid
  has_many :characters, through: :participations, dependent: :delete_all

  # ended_at
  validate :ended_at_is_valid_datetime
  validates :ended_at,
            allow_blank: true,
            uniqueness: true
  # started_at
  validates :started_at,
            presence: true,
            uniqueness: true
  validate :started_at_is_valid_datetime


  private

  def ended_at_is_valid_datetime
    unless ended_at.blank?
      errors.add(:ended_at, 'must be a valid datetime') if ((DateTime.parse(ended_at.to_s) rescue ArgumentError) == ArgumentError)
    end
  end
  def started_at_is_valid_datetime
    errors.add(:started_at, 'must be a valid datetime') if ((DateTime.parse(started_at.to_s) rescue ArgumentError) == ArgumentError)
  end
end
