class AddIndexes < ActiveRecord::Migration
  def change

    add_index :organizers,  :fk_org_code
    add_index :sections,    :to_point_id
    add_index :sections,    :point_id
    add_index :sections,    [:point_id, :to_point_id]
    add_index :log_entries, :point_id
    add_index :log_entries, :to_point_id
    add_index :log_entries, :crew_id
    add_index :log_entries, [:point_id, :to_point_id]
    add_index :log_entries, [:crew_id, :to_point_id]
    add_index :log_entries, [:crew_id, :point_id, :to_point_id]

  end
end
