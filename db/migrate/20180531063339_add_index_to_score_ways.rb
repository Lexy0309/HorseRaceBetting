class AddIndexToScoreWays < ActiveRecord::Migration[5.1]
  def change
    add_index :score_ways, :title
  end
end
