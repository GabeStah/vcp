class Setting < ActiveRecord::Base
  validates_time :raid_start_time
  validates_time :raid_end_time

end
