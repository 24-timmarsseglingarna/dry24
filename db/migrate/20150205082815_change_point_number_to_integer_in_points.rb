class ChangePointNumberToIntegerInPoints < ActiveRecord::Migration
  def change
    change_column :points, :number,  :integer
  end
end
