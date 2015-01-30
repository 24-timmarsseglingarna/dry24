class Crew < ActiveRecord::Base
  validates_presence_of :captain_name, :boat_name
end
