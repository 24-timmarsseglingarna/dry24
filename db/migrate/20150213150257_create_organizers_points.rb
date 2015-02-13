class CreateOrganizersPoints < ActiveRecord::Migration
  def change
    create_table :organizers_points do |t|
      t.integer :organizer_id
      t.integer :point_id

      t.timestamps
    end
    add_index :organizers_points, [:organizer_id, :point_id], :unique => true
  end
end
