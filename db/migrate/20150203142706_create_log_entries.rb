class CreateLogEntries < ActiveRecord::Migration
  def change
    create_table :log_entries do |t|
      t.integer :point_id
      t.integer :to_point_id
      t.datetime :from_time
      t.datetime :to_time
      t.string :description
      t.integer :poition

      t.timestamps null: false
    end
  end
end
