class CreateScoreWays < ActiveRecord::Migration[5.1]
  def change
    create_table :score_ways do |t|
      t.string :title
      t.integer :count
    end
  end
end
