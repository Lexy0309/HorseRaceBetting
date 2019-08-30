class CreateTrackStats < ActiveRecord::Migration[5.1]
  def change
    create_table :track_stats do |t|
      t.belongs_to :track
      t.belongs_to :race
      t.integer :total
      t.integer :score_total
      4.times do |i|
        t.integer "score#{i+1}"
        t.decimal "score#{i+1}_perc"
        t.decimal "score#{i+1}_weight"
        t.decimal "score#{i+1}_weight_corrected"
      end
    end
  end
end
