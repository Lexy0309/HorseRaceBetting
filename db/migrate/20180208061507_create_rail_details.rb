class CreateRailDetails < ActiveRecord::Migration[5.1]
  def change
    create_table :rail_details do |t|
      t.string :title
      t.belongs_to :race
    end
  end
end
