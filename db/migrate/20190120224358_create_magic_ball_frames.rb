class CreateMagicBallFrames < ActiveRecord::Migration[5.1]
  def change
    create_table :magic_ball_frames do |t|
      t.date :start_date
      t.integer :frame_start
      t.integer :frame_end
      t.integer :duration
      t.integer :horse_number
      t.boolean :is_win
      t.belongs_to :race
    end
  end
end
