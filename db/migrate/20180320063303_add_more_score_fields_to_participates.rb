class AddMoreScoreFieldsToParticipates < ActiveRecord::Migration[5.1]
  def change
    add_column :participates,:score5,:int
    add_column :participates,:score6,:int
    add_column :participates,:score7,:int
    add_column :participates,:score8,:int
  end
end
