class Crew < ActiveRecord::Base
  has_many :log_entries, -> { order("position ASC") }

  validates_presence_of :captain_name, :boat_name

  def start_point
    Point.find_by_number '555'
  end

  def range
    20 # nautical miles
  end

  def points_within_range
    within = start_point.nearbys(range, :units => :nm)
    within << start_point
    return within
  end

  def sections_within_range
    out_array = Array.new
    for point in points_within_range do
      for section in point.sections do
        unless (section.to_point.distance_to(start_point) > range) || (section.point.distance_to(start_point) > range)
          out_array << section
        end
      end
    end
    out_array
  end

end

