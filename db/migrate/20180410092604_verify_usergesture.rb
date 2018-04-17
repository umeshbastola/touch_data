class VerifyUsergesture < ActiveRecord::Migration[5.1]
  def change
  	create_table :geslogs do |t|
      t.integer :user_id
      t.integer :verified
    end
  end
end
