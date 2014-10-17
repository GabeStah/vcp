class Statistic < ActiveRecord::Base
  self.inheritance_column = 'record_type'

end
