class CreateHorsePositions < ActiveRecord::Migration[5.1]
  def change
    create_table :horse_positions do |t|
      t.belongs_to :race
      t.belongs_to :horse
      t.integer :horse_number
      t.integer :score_position
    end
  end
end
