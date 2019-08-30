class CreateRaceConditionDetails < ActiveRecord::Migration[5.1]
  def change
    create_table :race_condition_details do |t|
      t.string :title
      t.integer :rank
    end
    add_index :race_condition_details, :title, unique: true
  end
end
