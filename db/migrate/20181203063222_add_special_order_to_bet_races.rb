class AddSpecialOrderToBetRaces < ActiveRecord::Migration[5.1]
  def change
    add_column :bet_races, :special_order, :integer
  end
end
