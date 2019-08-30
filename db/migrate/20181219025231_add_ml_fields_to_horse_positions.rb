class AddMlFieldsToHorsePositions < ActiveRecord::Migration[5.1]
  def change
    add_column :horse_positions, :ml_rank, :integer
    add_column :horse_positions, :ml_score, :decimal
  end
end
