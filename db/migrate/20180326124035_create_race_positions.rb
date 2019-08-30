class CreateRacePositions < ActiveRecord::Migration[5.1]
  def change
    create_table :race_positions do |t|
      t.string :score_fields
      t.belongs_to :race
    end
    remove_column :races, :score_fields
  end
end
