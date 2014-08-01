class Event < ActiveRecord::Base
  self.inheritance_column = 'actor_type'

end