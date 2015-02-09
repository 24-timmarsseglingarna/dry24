class ChangePointNumberToIntegerInPoints < ActiveRecord::Migration
  def change
    change_column :points, :number,  'integer USING CAST("number" AS integer)'
  end
end