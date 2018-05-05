class NumStrokes < ActiveRecord::Migration[5.1]
  def change
  	add_column :tgestures, :num_stroke, :integer
  end
end
