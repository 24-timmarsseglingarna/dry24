class AddLatitudeAndLongitudeToPoint < ActiveRecord::Migration
  def change
    add_column :points, :latitude, :float
    add_column :points, :longitude, :float
  end
end
