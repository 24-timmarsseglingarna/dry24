class LogEntry < ActiveRecord::Base
  belongs_to :crew
  belongs_to :point
  belongs_to :to_point, :class_name => "Point"
  acts_as_list scope: :crew
end
