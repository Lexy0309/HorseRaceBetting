class CreateRaTrackRecords < ActiveRecord::Migration[5.1]
  def change
    create_table :ra_track_records do |t|
      t.integer :code
      t.date :race_date
      t.integer :race_number
      t.integer :distance
      t.decimal :duration

      t.belongs_to :race
      t.belongs_to :ra_track
    end
  end
end
