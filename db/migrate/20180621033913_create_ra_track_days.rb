class CreateRaTrackDays < ActiveRecord::Migration[5.1]
  def change
    create_table :ra_track_days do |t|
      t.string :rating_title
      t.integer :rating_code
      t.string :rail_position
      t.string :rail_position_last
      t.string :weather
      t.string :surface
      t.string :comments
      t.string :irrigation
      t.string :rainfall
      t.string :racing_direction
      t.belongs_to :ra_track
      t.belongs_to :ra_meeting
    end
  end
end
