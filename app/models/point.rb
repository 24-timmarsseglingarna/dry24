class Point < ActiveRecord::Base
  include  ActionView::Helpers::OutputSafetyHelper
  validates :number, length: {in: 1..4}, uniqueness: true, numericality: { only_integer: true, greater_than: 0 }
  validates_length_of :name, :minimum => 2, :allow_blank => true
  has_many :sections

  geocoded_by :full_address
  after_validation :geocode

  def full_address
    'Stavsnäs vinterhamn, Värmdö'
  end

  def latitude
    (lat.split[0].to_d + lat.split[1].gsub(/,/, ".").to_d/60).to_f
  end

  def longitude
    (long.split[0].to_d + long.split[1].gsub(/,/, ".").to_d/60).to_f
  end

  def number_name
    out = number
    out += ' ' + name unless name.blank?
    out
  end

  def targets
    target_points = []
    for section in self.sections do
      target_points << section.to_point
    end
  end

  def near
    #Point.near([latitude, longitude], 60, :units => :nm)
    nearbys(10, :units => :nm)

  end

end
