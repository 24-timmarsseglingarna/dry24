class Section < ActiveRecord::Base
  belongs_to :point
  belongs_to :to_point, :class_name => "Point"
  validates_presence_of :point_id, :to_point_id, :distance
  validates :distance, :presence => true
  validates_numericality_of :distance, greater_than_or_equal_to: 0

  def other_end
    str = to_point.number.to_s
    str += ' ' + to_point.name unless to_point.name.blank?
    str += ' (' + distance.to_s + ')' unless distance.blank?
    str
  end

  def opposite
    Section.find_by(point: to_point, to_point: point)
  end
end
