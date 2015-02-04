class AddDistanceToLogEntry < ActiveRecord::Migration
  def change
    add_column :log_entries, :distance, :float, :default => 0
  end
end