class AddRawFieldsToHorsePositions < ActiveRecord::Migration[5.1]
  def change
    10.times do |i|
      add_column :horse_positions, "score#{i+1}_raw", :decimal
    end
  end
end
