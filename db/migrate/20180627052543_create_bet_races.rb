class CreateBetRaces < ActiveRecord::Migration[5.1]
  def change
    create_table :bet_races do |t|
      t.belongs_to :race
      t.belongs_to :bet
    end
  end
end
