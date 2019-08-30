class CreateParticipateDetails < ActiveRecord::Migration[5.1]
  def change
    create_table :participate_details do |t|
      t.integer :horse_number
      t.decimal :fixed_odd_win
      t.decimal :fixed_odd_place
      t.decimal :tote_win
      t.decimal :tote_place
      t.decimal :quinella
      t.decimal :exacta
      t.decimal :trifecta
      t.decimal :running_double
      t.decimal :daily_double
      t.decimal :quaddie
      t.decimal :first_four
      t.decimal :early_quaddie
      t.integer :duet_pair
      t.decimal :duet
      t.belongs_to :race
    end
  end
end
