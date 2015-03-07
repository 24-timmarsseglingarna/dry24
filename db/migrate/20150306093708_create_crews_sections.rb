class CreateCrewsSections < ActiveRecord::Migration
  def change
    create_table :crews_sections do |t|
      t.integer :crew_id
      t.integer :section_id
    end
    add_index :crews_sections, :crew_id
    add_index :crews_sections, :section_id
    add_index :crews_sections, [:crew_id, :section_id], :unique => true
  end
end
