class CreateGroupRaces < ActiveRecord::Migration[5.1]
  def change
    create_table :group_races do |t|
      t.date :start_date
      t.string :venue
      t.integer :distance
      t.integer :prize
      t.integer :group_level
      t.string :title
      t.string :race_type_short
      t.string :race_type_full
    end
  end
end
