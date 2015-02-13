class CreateOrganizers < ActiveRecord::Migration
  def change
    create_table :organizers do |t|
      t.string :name
      t.string :fk_org_code

      t.timestamps null: false
    end
  end
end
