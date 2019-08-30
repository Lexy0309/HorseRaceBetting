class AddFieldsToRaceRewards < ActiveRecord::Migration[5.1]
  def change
    add_column :race_rewards,:running_double,:string
    add_column :race_rewards,:daily_double,:string
    add_column :race_rewards,:quaddie,:string
    add_column :race_rewards,:early_quaddie,:string
  end
end
