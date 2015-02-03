class CreateSections < ActiveRecord::Migration
  def change
    create_table :sections do |t|
      t.integer :point_id
      t.integer :to_point_id
      t.float :distance

      t.timestamps null: false
    end
  end
end
