class LogEntry < ActiveRecord::Base
  belongs_to :crew
  acts_as_list scope: :crew
end
