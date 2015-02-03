class Section < ActiveRecord::Base
  belongs_to :point
  belongs_to :to_point, :class_name => "Point"
  validates_presence_of :point_id, :to_point_id, :distance
  validates :distance, :presence => true
  validates_numericality_of :distance, greater_than_or_equal_to: 0

  def other_end
    to_point.number + ' ' + to_point.name + ' (' + self.distance.to_s + ')'
  end
end