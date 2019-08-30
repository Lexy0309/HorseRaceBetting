class AddMachineLearningToScorecard < ActiveRecord::Migration[5.1]
  def change
    add_column :scorecards, :count_machine_learning,:int
    add_column :scorecards, :perc_machine_learning,:int
  end
end
