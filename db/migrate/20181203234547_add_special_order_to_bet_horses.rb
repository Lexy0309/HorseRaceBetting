class AddSpecialOrderToBetHorses < ActiveRecord::Migration[5.1]
  def change
    add_column :bet_horses, :special_order, :integer
  end
end
