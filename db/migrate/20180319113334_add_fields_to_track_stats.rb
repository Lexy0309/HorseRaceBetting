class AddFieldsToTrackStats < ActiveRecord::Migration[5.1]
  def change
    add_column :track_stats, :top_round, :decimal
    add_column :track_stats, :top_count, :integer
    add_column :track_stats, :top_sum, :integer
  end
end
