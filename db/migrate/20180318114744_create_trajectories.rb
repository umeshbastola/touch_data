class CreateTrajectories < ActiveRecord::Migration[5.1]
  def change
    create_table :trajectories do |t|
      t.integer :user_id
      t.integer :gesture_id
      t.integer :is_password
      t.integer :stroke_seq
      t.integer :exec_num
      t.text   :points, array: true, default: []
      t.timestamps
    end

  end
end
