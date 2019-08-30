class CreateRaces < ActiveRecord::Migration[5.1]
  def change
    create_table :races do |t|
      t.belongs_to :track
      t.string :title
      t.integer :distance
      t.string :condition
      t.string :race_class
      t.integer :race_number
      t.integer :race_dt
      t.date :start_date
      t.decimal :duration
    end
  end
end
