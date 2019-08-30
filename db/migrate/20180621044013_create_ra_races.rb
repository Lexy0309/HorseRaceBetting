class CreateRaRaces < ActiveRecord::Migration[5.1]
  def change
    create_table :ra_races do |t|
      t.integer :code
      t.integer :race_number
      t.date :race_date
      t.string :name_race_full
      t.string :name_race_form
      t.string :name_race_news
      t.integer :start_time
      t.string :time_at_venue
      t.integer :nominations_race_number
      t.integer :total_excluding_bonuses
      t.integer :welfare_fund
      t.integer :distance
      t.integer :track_straight
      t.integer :track_circumference


      t.belongs_to :ra_track
      t.belongs_to :ra_track_day
      t.belongs_to :ra_meeting
      t.belongs_to :ra_track_record
    end
  end
end
