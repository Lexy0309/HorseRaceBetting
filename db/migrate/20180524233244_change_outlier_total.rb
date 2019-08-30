class ChangeOutlierTotal < ActiveRecord::Migration[5.1]
  def change
    change_column :horse_positions, :outlier_count, :decimal
  end
end
