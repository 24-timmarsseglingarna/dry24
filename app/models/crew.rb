class Crew < ActiveRecord::Base
  has_many :log_entries, -> { order('position ASC') }
  belongs_to :last_point, :class_name => "Point"

  validates_presence_of :captain_name, :boat_name
  accepts_nested_attributes_for :log_entries

  def start_point
    Point.find_by_number '555'
  end


  def range
    60 # nautical miles
  end

  def points_within_range
    within = last_point.nearbys(range, :units => :nm)
    within << last_point
    within
  end

  def sections_within_range
    out_array = Array.new
    for point in points_within_range do
      for section in point.sections do
        unless (section.to_point.distance_to(last_point) > range) || (section.point.distance_to(last_point) > range)
          out_array << section
        end
      end
    end
    out_array
  end

  def add_leg section=nil
    unless section.blank?
      log_entry = LogEntry.new
      log_entry.crew_id = self.id
      log_entry.from_time = DateTime.now
      log_entry.point_id = section.point_id
      log_entry.to_point_id = section.to_point_id
      log_entry.save!
      last_point = log_entry.to_point
    end
  end
end

