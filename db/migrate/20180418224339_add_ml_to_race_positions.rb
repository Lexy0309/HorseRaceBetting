class AddMlToRacePositions < ActiveRecord::Migration[5.1]
  def change
    add_column :race_positions, :ml_top, :integer
  end
end
