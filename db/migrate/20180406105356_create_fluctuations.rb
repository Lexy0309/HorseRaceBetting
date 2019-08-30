class CreateFluctuations < ActiveRecord::Migration[5.1]
  def change
    create_table :fluctuations do |t|
      t.belongs_to :race
      t.integer :horse_number
      t.decimal :open_price
      t.decimal :highest_price
      t.decimal :lowest_price
      t.decimal :current_price
    end
  end
end
