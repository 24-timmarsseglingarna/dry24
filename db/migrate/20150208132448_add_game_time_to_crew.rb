class AddGameTimeToCrew < ActiveRecord::Migration
  def change
    add_column :crews, :game_time, :datetime
  end
end
