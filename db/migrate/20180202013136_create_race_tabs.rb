class CreateRaceTabs < ActiveRecord::Migration[5.1]
  def change
    create_table :race_tabs do |t|
      t.belongs_to :race
      t.string :condition
      t.string :race_class
    end
  end
end
