class AddMlPositionToHorsePositions < ActiveRecord::Migration[5.1]
  def change
    add_column :horse_positions, :ml_position, :integer
  end
end
