class CreateMagicBallFramesRaces < ActiveRecord::Migration[5.1]
  def change
    create_table :magic_ball_frames_races do |t|
      t.integer :magic_ball_frame_id
      t.integer :race_id
    end
  end
end
