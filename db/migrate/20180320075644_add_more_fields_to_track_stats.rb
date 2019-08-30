class AddMoreFieldsToTrackStats < ActiveRecord::Migration[5.1]
  def change
    4.times do |i|
      add_column :track_stats, "score#{i+5}", :integer
      add_column :track_stats, "score#{i+5}_perc", :decimal
      add_column :track_stats, "score#{i+5}_weight", :decimal
      add_column :track_stats, "score#{i+5}_weight_corrected", :decimal
    end
  end
end
