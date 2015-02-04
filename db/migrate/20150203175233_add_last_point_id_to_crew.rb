class AddLastPointIdToCrew < ActiveRecord::Migration
  def change
    add_column :crews, :last_point_id, :integer
  end
end
