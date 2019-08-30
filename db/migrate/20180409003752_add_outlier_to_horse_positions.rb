class AddOutlierToHorsePositions < ActiveRecord::Migration[5.1]
  def change
    add_column :horse_positions, :outlier_score, :integer
    add_column :horse_positions, :outlier_count, :integer
  end
end
