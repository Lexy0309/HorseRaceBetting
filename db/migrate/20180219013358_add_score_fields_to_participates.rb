class AddScoreFieldsToParticipates < ActiveRecord::Migration[5.1]
  def change
    add_column :participates,:score,:int
    add_column :participates,:score1,:int
    add_column :participates,:score2,:int
    add_column :participates,:score3,:int
    add_column :participates,:score4,:int
    add_column :participates,:score_position,:int
  end
end
