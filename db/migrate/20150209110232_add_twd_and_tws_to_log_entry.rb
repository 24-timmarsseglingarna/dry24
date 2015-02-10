class AddTwdAndTwsToLogEntry < ActiveRecord::Migration
  def change
    add_column :log_entries, :twd, :float
    add_column :log_entries, :tws, :float
  end
end
