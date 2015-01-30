class CreateCrews < ActiveRecord::Migration
  def change
    create_table :crews do |t|
      t.string :boat_name
      t.string :captain_name
      t.string :captain_email

      t.timestamps null: false
    end
  end
end
