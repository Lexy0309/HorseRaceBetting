class AddTempScores < ActiveRecord::Migration[5.1]
  def change
    add_column :horse_positions, :score_temp, :int
    add_index :horse_positions, :score_temp
    add_column :race_positions, :score_temp, :int
    add_index :race_positions, :score_temp
  end
end
