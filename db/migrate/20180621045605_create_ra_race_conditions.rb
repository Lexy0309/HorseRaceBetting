class CreateRaRaceConditions < ActiveRecord::Migration[5.1]
  def change
    create_table :ra_race_conditions do |t|
      t.string :condition_type
      t.string :condition_id
      t.string :code
      t.string :short
      t.string :medium
      t.string :long
      t.belongs_to :ra_race
    end
  end
end