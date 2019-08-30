class AddScores912ToParticipates < ActiveRecord::Migration[5.1]
  def change
    2.times do |i|
      add_column :participates,"score#{i+9}",:int
      add_column :track_stats, "score#{i+9}", :integer
      add_column :track_stats, "score#{i+9}_perc", :decimal
      add_column :track_stats, "score#{i+9}_weight", :decimal
      add_column :track_stats, "score#{i+9}_weight_corrected", :decimal
    end
  end
end
