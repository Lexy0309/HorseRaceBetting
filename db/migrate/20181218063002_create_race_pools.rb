class CreateRacePools < ActiveRecord::Migration[5.1]
  def change
    create_table :race_pools do |t|
      t.decimal :win
      t.decimal :place
      t.decimal :quinella
      t.decimal :exacta
      t.decimal :duet
      t.decimal :trifecta
      t.decimal :first_four
      t.decimal :running_double
      t.decimal :daily_double
      t.decimal :early_quaddie
      t.decimal :quaddie
      t.decimal :big_6
      t.belongs_to :race
    end
  end
end
