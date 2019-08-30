class AddExplainedFieldsToParticipates < ActiveRecord::Migration[5.1]
  def change
    add_column :participates, :sectional_time, :decimal
    add_column :participates, :prize_money, :int
    add_column :participates, :horse_prize_money, :int
    add_column :participates, :open_price, :decimal
    add_column :participates, :fluctuation, :decimal
    add_column :participates, :starting_price, :decimal
  end
end
