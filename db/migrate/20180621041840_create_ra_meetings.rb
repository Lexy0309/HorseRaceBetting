class CreateRaMeetings < ActiveRecord::Migration[5.1]
  def change
    create_table :ra_meetings do |t|
      t.string :code_type
      t.string :category
      t.string :stage
      t.string :phase
      t.integer :nomination_close
      t.integer :acceptance_close
      t.integer :riders_close
      t.integer :weights_publishing
      t.boolean :dual_track
      t.string :meeting_type
      t.date :meet_date
      t.string :day_night
      t.integer :races_count
      t.boolean :tab_status
      t.belongs_to :track
    end
  end
end
