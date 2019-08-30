class AddStatFieldsToRaces < ActiveRecord::Migration[5.1]
  def change
    add_column :races, :best_position, :string
    add_column :races, :best_position_value, :decimal
    add_column :races, :jockey_id, :integer
    add_column :races, :jockey_winrate_value, :decimal
    add_column :races, :horse_id, :integer
    add_column :races, :horse_special_value, :decimal
  end
end
