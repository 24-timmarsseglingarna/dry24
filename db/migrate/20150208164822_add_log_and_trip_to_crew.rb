class AddLogAndTripToCrew < ActiveRecord::Migration
  def change
    add_column :crews, :log, :float, :default => 0
    add_column :crews, :trip, :float, :default => 0
  end
end
