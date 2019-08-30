class AddSpecialOrderToBets < ActiveRecord::Migration[5.1]
  def change
    add_column :bets, :special_order, :integer
  end
end
