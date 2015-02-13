class Organizer < ActiveRecord::Base
  validates :name, presence: true, uniqueness: true
  has_and_belongs_to_many :start_points, :class_name => "Point"
end
