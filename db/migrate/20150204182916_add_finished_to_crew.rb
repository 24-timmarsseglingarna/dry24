class AddFinishedToCrew < ActiveRecord::Migration
  def change
    add_column :crews, :finished, :boolean, :default => false
  end
end
