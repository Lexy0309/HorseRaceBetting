class CreateBetHorses < ActiveRecord::Migration[5.1]
  def change
    create_table :bet_horses do |t|
      t.integer :horse_number
      t.integer :position
      t.belongs_to :bet_race
    end
  end
end
