class Point < ActiveRecord::Base
  include ActionView::Helpers::NumberHelper
  include ActionView::Helpers::OutputSafetyHelper

  default_scope { order('number ASC') }
  has_many :sections, :dependent => :destroy
  has_and_belongs_to_many :organizers
  has_many :crews

  validates :number, numericality: { only_integer: true, greater_than: 0 }
  validates_length_of :name, :minimum => 2, :allow_blank => true
  validates_numericality_of :longitude, :greater_than_or_equal_to => -90, :less_than_or_equal_to => 90, :allow_nil => true
  validates_numericality_of :latitude, :greater_than_or_equal_to => -180, :less_than_or_equal_to => 180, :allow_nil => true

  geocoded_by :full_address
  after_validation :geocode,  if: ->(obj){ obj.full_address.present?   }

  def full_address
    nil
  end

  def lat
    if latitude.present?
      if latitude < 0
        hemisphere = 'S'
      else
        hemisphere = 'N'
      end
       "#{hemisphere} #{latitude.floor}°#{number_with_precision(((latitude-latitude.floor)*60), precision: 2) }'"
    else
      nil
    end
  end

  def long
    if longitude.present?
      if longitude < 0
        hemisphere = 'W'
      else
        hemisphere = 'E'
      end
      "#{hemisphere} #{longitude.floor}°#{number_with_precision(((longitude-longitude.floor)*60), precision: 2) }'"
    else
      nil
    end
  end

  def number_name
    out = number.to_s
    unless name.blank?
      out += ' ' + name
    end
    out
  end

  def targets
    target_points = []
    for section in sections do
      target_points << section.to_point
    end
    target_points
  end

  def within_range(range = 20)
    within = nearbys(range, :units => :nm)
    within << self
    within
  end

  def sections_within_range(range = 20)
    within = Array.new
    for point in within_range(range) do
      for section in point.sections do
        unless within.include?(section) || within.include?(section.opposite)
          unless (section.to_point.distance_to(self) > range * 1852 / 1609) || (section.point.distance_to(self) > range * 1852 / 1609)
            within << section
          end
        end
      end
    end
    within
  end

end
