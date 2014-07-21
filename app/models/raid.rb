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
  # Dates should be logical
  validate :dates_are_consecutive


  def ended_at=(t)
    t = DateTime.strptime(t, DATETIME_FORMAT) unless t.blank? || t.class == 'DateTime'
    super(t)
  end

  def full_title
    return "#{zone.name} @ #{I18n.l(started_at)}"
  end

  def started_at=(t)
    t = DateTime.strptime(t, DATETIME_FORMAT) unless t.blank? || t.class == 'DateTime'
    super(t)
  end

  def zone=(z)
    z = Zone.find(z) unless z.class == 'Zone'
    super(z)
  end


  private

  def dates_are_consecutive
    unless ended_at.blank? || started_at.blank?
      if started_at > ended_at
        errors.add(:ended_at, 'cannot occur before Start Date.')
      end
    end
  end

  def ended_at_is_valid_datetime
    unless ended_at.blank?
      errors.add(:ended_at, 'must be a valid datetime') if ((DateTime.parse(ended_at.to_s) rescue ArgumentError) == ArgumentError)
    end
  end
  def started_at_is_valid_datetime
    errors.add(:started_at, 'must be a valid datetime') if ((DateTime.parse(started_at.to_s) rescue ArgumentError) == ArgumentError)
  end
end
