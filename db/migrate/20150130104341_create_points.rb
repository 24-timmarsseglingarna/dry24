class CreatePoints < ActiveRecord::Migration
  def change
    create_table :points do |t|
      t.string :number
      t.string :name
      t.string :lat
      t.string :long
      t.string :definition

      t.timestamps null: false
    end
  end
end
