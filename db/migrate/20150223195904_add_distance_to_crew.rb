class AddDistanceToCrew < ActiveRecord::Migration
  def up
    add_column :crews, :distance, :float, :default => 0

    for crew in Crew.all
      crew.update(:distance => crew.distance_sum)
    end

  end

  def down
    remove_column :crews, :distance
  end
end
