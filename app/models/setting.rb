class Setting < ActiveRecord::Base
  validates_time :raid_start_time
  validates_time :raid_end_time

  validates :tardiness_cutoff_time,
            allow_blank: true,
            numericality: true

end
