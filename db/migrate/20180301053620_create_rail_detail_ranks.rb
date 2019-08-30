class CreateRailDetailRanks < ActiveRecord::Migration[5.1]
  def change
    create_table :rail_detail_ranks do |t|
      t.string :title
      t.integer :rank
    end
    add_index :rail_detail_ranks, :title, unique: true
  end
end
