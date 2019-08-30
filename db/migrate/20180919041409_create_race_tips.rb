class CreateRaceTips < ActiveRecord::Migration[5.1]
  def change
    create_table :race_tips do |t|
      t.integer :source #1 racenet; 2 tab
      t.integer :place1
      t.integer :place2
      t.integer :place3
      t.integer :place4
      t.belongs_to :race
    end
  end
end
