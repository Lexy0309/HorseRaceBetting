class CreateRaTracks < ActiveRecord::Migration[5.1]
  def change
    create_table :ra_tracks do |t|
      t.string :venue_title
      t.string :venue_descr
      t.string :venue_abbr
      t.integer :venue_code
      t.string :track_title
      t.integer :track_code
      t.belongs_to :ra_state
    end
    add_index :ra_tracks, :venue_code
    add_index :ra_tracks, :track_code
  end
end


