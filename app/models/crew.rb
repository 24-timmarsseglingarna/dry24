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

  # True Wind Speed
  def tws
    10 / (0.54 * 3.6) # depends on location and time
  end

  # Wind direction
  def twd
    90 # depends on location and time
  end

  # True wind angle
  def twa
    true_wind_angle = twd - cog
    true_wind_angle -= 360 if true_wind_angle > 180
    true_wind_angle += 360 if true_wind_angle < -180
    true_wind_angle
  end

  # Apparent wind speed
  def aws
    # x axis - the boat's direction
    # y axis - abeam to port
    aws_x = tws * Math::cos(twa * 2 * Math::PI / 360) + sog / (0.54 * 3.6) # 1/(.54*3.6) knots to m/s
    aws_y = tws * Math::sin(twa * 2 * Math::PI / 360)
    aws_res = Math::sqrt(aws_x**2 + aws_y**2)
    aws_res
  end

  # Apparent wind angle
  def awa
    if aws > 0.05
      aws_x = tws * Math::cos(twa * 2 * Math::PI / 360) + sog / (0.54 * 3.6)
      aws_y = tws * Math::sin(twa * 2 * Math::PI / 360)
      Math::atan(aws_y/aws_x) / 2 / Math::PI * 360
    else  
      0
    end
  end

  # Speed over ground
  def sog
    #4 # depends on polar diagram, twa, tws

    speed_at_10_knots_wind = Spliner::Spliner.new [52, 60, 75, 90, 110, 120, 135, 150, 210, 225],
                                                  [6.05, 6.32, 6.59, 6.78, 6.68, 6.50, 6.11, 5.50, 5.50, 6.11]
    twa_abs = twa.abs
    if twa_abs < 52
      speed = speed_at_10_knots_wind[52] * Math::cos((52 - twa_abs) * 2 * Math::PI / 360)
    else
      speed = speed_at_10_knots_wind[twa_abs]
    end
    speed
  end

  # Velocity made good
  def vmg
    #dist = 0
    log_entry = LogEntry.where(crew: self, to_point: last_point).last
    if log_entry.present?
      if log_entry.point.present? && log_entry.to_point.present?
        dist = log_entry.point.distance_from(log_entry.to_point) / 1609 * 1852
        duration = (log_entry.to_time - log_entry.from_time)
      end
    end
    sog
  end

  def cog
    out = 0
    log_entry = LogEntry.where(crew: self, to_point: last_point).last
    if log_entry.present?
      if log_entry.point.present? && log_entry.to_point.present?
        out = log_entry.point.bearing_to log_entry.to_point
      end
    end
    out
  end

  def game_time
    DateTime.now
  end

end

