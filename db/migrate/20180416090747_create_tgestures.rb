class CreateTgestures < ActiveRecord::Migration[5.1]
  def change
    create_table :tgestures do |t|
      t.string :name,
      t.timestamps
    end
  end
end
