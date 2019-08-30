class AddScorePositionReorderedToHorsePositions < ActiveRecord::Migration[5.1]
  def change
    add_column :horse_positions, :score_position_reordered, :integer
  end
end
