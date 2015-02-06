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

  def tripled_rounding? point
    roundings = Array.new
    for log_entry in log_entries do
      roundings << log_entry.to_point unless log_entry.to_point.blank?
    end
    no_of_uses = roundings.count(point)
    no_of_uses-= 2 if point == start_point
    no_of_uses > 2
  end

  def tripled_sections? log_entry
    (LogEntry.where(crew: self, point: log_entry.point, to_point: log_entry.to_point).count +
     LogEntry.where(crew: self, point: log_entry.to_point, to_point: log_entry.point).count) > 2
  end

end

