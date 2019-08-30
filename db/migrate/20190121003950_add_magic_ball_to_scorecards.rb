class AddMagicBallToScorecards < ActiveRecord::Migration[5.1]
  def change
    add_column :scorecards, :count_magic_ball, :integer
    add_column :scorecards, :perc_magic_ball, :integer
  end
end
