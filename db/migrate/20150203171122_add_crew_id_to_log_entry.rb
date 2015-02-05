class AddCrewIdToLogEntry < ActiveRecord::Migration
  def change
    add_column :log_entries, :crew_id, :integer
  end
end
