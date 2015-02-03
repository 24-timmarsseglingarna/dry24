class Crew < ActiveRecord::Base
  validates_presence_of :captain_name, :boat_name

  def start_point
    Point.find_by_number '555'
  end

  def points_within_range
    within = start_point.nearbys(4, :units => :nm)
    within << start_point
    return within
  end

  def sections_within_range
    out_array = Array.new
    for point in points_within_range do
      for section in point.sections do
        out_array << section
      end
    end
    out_array
  end

end
