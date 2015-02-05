class RemoveLatAndLongFromPoints < ActiveRecord::Migration
  def change
    remove_column :points, :lat
    remove_column :points, :long
  end
end
