class MoveScoresToHorsePositions < ActiveRecord::Migration[5.1]
  def change
    remove_column :participates, :score
    remove_column :participates, :score1
    remove_column :participates, :score2
    remove_column :participates, :score3
    remove_column :participates, :score4
    remove_column :participates, :score5
    remove_column :participates, :score6
    remove_column :participates, :score7
    remove_column :participates, :score8
    remove_column :participates, :score9
    remove_column :participates, :score10
    remove_column :participates, :score_position
    add_column :horse_positions, :score, :int
    add_column :horse_positions, :score1, :int
    add_column :horse_positions, :score2, :int
    add_column :horse_positions, :score3, :int
    add_column :horse_positions, :score4, :int
    add_column :horse_positions, :score5, :int
    add_column :horse_positions, :score6, :int
    add_column :horse_positions, :score7, :int
    add_column :horse_positions, :score8, :int
    add_column :horse_positions, :score9, :int
    add_column :horse_positions, :score10, :int
  end
end
