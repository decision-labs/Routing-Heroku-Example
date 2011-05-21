class SpacialdbBase < ActiveRecord::Base
  establish_connection(::SpacialdbConnectionConfig)
  self.abstract_class = true
end
