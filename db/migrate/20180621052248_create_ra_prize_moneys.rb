class CreateRaPrizeMoneys < ActiveRecord::Migration[5.1]
  def change
    create_table :ra_prize_moneys do |t|
      t.integer :amount
      t.integer :position
      t.belongs_to :ra_race
    end
  end
end
