class Point < ActiveRecord::Base
  include  ActionView::Helpers::OutputSafetyHelper
  validates :number, length: {in: 1..4}, uniqueness: true, numericality: { only_integer: true, greater_than: 0 }
  validates_length_of :name, :minimum => 2, :allow_blank => true
  has_many :sections

  def lat_d
    lat.split[0].to_d + lat.split[1].gsub(/,/, ".").to_d/60
  end

  def long_d
    long.split[0].to_d + long.split[1].gsub(/,/, ".").to_d/60
  end

  def number_name
    out = number
    out += ' ' + name unless name.blank?
    out
  end

  def targets
    target_points = Array.new
    for section in self.sections do
      target_points << section.to_point
    end
    target_points
  end

end
  