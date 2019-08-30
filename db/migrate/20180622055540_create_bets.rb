class CreateBets < ActiveRecord::Migration[5.1]
  def change
    create_table :bets do |t|
      t.date :start_date
      t.integer :category
      t.decimal :price
      t.decimal :amount
      t.decimal :reward
    end
    add_index :bets, :category
  end
end
