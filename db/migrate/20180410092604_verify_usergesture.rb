class VerifyUsergesture < ActiveRecord::Migration[5.1]
  def change
  	create_table :gestures do |t|
      t.integer :user_id
      t.integer :verified
    end
  end
end
