class Crew < ActiveRecord::Base
  has_many :log_entries, -> { order('position ASC') }
  belongs_to :last_point, :class_name => "Point"
  belongs_to  :start_point, :class_name => "Point"

  validates_presence_of :captain_name, :boat_name, :start_point
  accepts_nested_attributes_for :log_entries
  after_create :add_first_log_entry
  before_create :start_details


  def start_time
    log_entry = LogEntry.where(crew: self).first
    log_entry.to_time
  end

  def handicap
    1.146
  end

  def distance_sum
    sum = 0.0
    for log_entry in log_entries do
      sum += log_entry.distance.to_f
    end
    sum
  end

  def range
    24 / 2 * 7 * handicap # nautical miles
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
    t = game_time.to_f - start_time.to_f
    tws_spline = Spliner::Spliner.new   [-6349,-2739,846,4447,8055,15252,18856,26049,29649,33253,36855,44053,48251,65654,72854,76444,80062,90846,94448,98047,101649,112510,116113,119776,123371,209771],
                                        [5,6,5,4,5,5,4,3,4,4,2,3,2,1,3,2,4,6,4,6,5,4,3,2,2,2]
    tws_spline[t]
  end

  # Wind direction
  def twd
    t = game_time.to_f - start_time.to_f
    twd_spline = Spliner::Spliner.new   [-6349,-2739,846,4447,8055,15252,18856,26049,29649,33253,36855,44053,48251,65654,72854,76444,80062,90846,94448,98047,101649,112510,116113,119776,123371,209771],
                                        [180,135,135,90,135,180,180,225,180,225,225,225,225,225,225,180,180,180,180,180,180,180,180,180,135,135]
    twd_spline[t]
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
    speed_at_10_knots_wind = Spliner::Spliner.new [52, 60, 75, 90, 110, 120, 135, 150, 210, 225],
                                                  [6.05, 6.32, 6.59, 6.78, 6.68, 6.50, 6.11, 5.50, 5.50, 6.11]
    twa_abs = twa.abs
    if twa_abs < 52 # TODO viewed SOG should not be reduced when tacking.
      speed = speed_at_10_knots_wind[52]
    else
      speed = speed_at_10_knots_wind[twa_abs]
    end
    speed
  end

  # Velocity made good
  def vmg
    speed_at_10_knots_wind = Spliner::Spliner.new [52, 60, 75, 90, 110, 120, 135, 150, 210, 225],
                                                  [6.05, 6.32, 6.59, 6.78, 6.68, 6.50, 6.11, 5.50, 5.50, 6.11]
    twa_abs = twa.abs
    if twa_abs < 52 # TODO viewed SOG should not be reduced when tacking.
      speed = speed_at_10_knots_wind[52] * Math::cos((52 - twa_abs) * 2 * Math::PI / 360)
    else
      speed = speed_at_10_knots_wind[twa_abs]
    end
    speed
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


  private

  def start_details
    #self.start_point = Point.find_by_number '555'
    #self.last_point = start_point
    self.game_time = DateTime.now.beginning_of_year + 5.months + 5.days + 11.hours
  end

  def add_first_log_entry
    log_entry = log_entries.build( :to_point => start_point,
                                   :point => nil,
                                   :from_time => nil,
                                   :to_time =>   game_time)
    log_entry.save
  end

end

