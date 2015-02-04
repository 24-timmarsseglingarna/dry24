class ChangeColumnNameLogEntryPosition < ActiveRecord::Migration
  def change
    rename_column(:log_entries,:poition, :position )
  end
end
