class AddStartPointIdToCrew < ActiveRecord::Migration
  def change
    add_column :crews, :start_point_id, :integer
  end
end
