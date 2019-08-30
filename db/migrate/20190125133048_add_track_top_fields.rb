class AddTrackTopFields < ActiveRecord::Migration[5.1]
  def change
    add_column :tracks, :average_daily_winrate, :integer
    add_column :tracks, :best_daily_winrate, :integer
    add_column :tracks, :jockey_id, :integer
    add_column :tracks, :jockey_winrate, :integer
    add_column :tracks, :horse_id, :integer
    add_column :tracks, :horse_winrate, :integer
  end
end
