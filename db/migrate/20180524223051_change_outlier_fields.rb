class ChangeOutlierFields < ActiveRecord::Migration[5.1]
  def change
    19.times do |i|
      index = i+1
      change_column :horse_positions, "outlier#{index}", :decimal
    end
  end
end
