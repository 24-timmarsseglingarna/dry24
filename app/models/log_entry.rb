class LogEntry < ActiveRecord::Base
  belongs_to :crew
  belongs_to :point
  belongs_to :to_point, :class_name => "Point"

  acts_as_list scope: :crew

  after_create  :insert_wind, if: :to_point


  def from_to
    if point.present? && to_point.present?
      "#{point.number}–#{to_point.number}"
    end
  end

  private

  def insert_wind
    self.twd = crew.twd
    self.tws = crew.tws
    crew.trip = (crew.sog / crew.vmg) * self.distance unless (crew.vmg == 0)
    crew.log += crew.trip
    crew.save
    self.save
  end

end
