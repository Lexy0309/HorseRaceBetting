class AddOutlierFieldsToHorsePositions < ActiveRecord::Migration[5.1]
  def change
    19.times do |i|
      index = i+1
      add_column :horse_positions, "outlier#{index}", :int
    end
  end
end
