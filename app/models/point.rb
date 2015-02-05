class Point < ActiveRecord::Base
  include ActionView::Helpers::NumberHelper

  default_scope { order('number ASC') }
  has_many :sections

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

end
