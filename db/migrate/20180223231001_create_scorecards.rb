class CreateScorecards < ActiveRecord::Migration[5.1]
  def change
    create_table :scorecards do |t|
      t.belongs_to :track
      t.date :start_date
      t.integer :total_races

      t.integer :count_top_selection
      t.integer :perc_top_selection

      t.integer :count_2nd_selection
      t.integer :perc_2nd_selection

      t.integer :count_top_selection_placed
      t.integer :perc_top_selection_placed

      t.integer :count_quinella_top2
      t.integer :perc_quinella_top2

      t.integer :count_quinella_top3
      t.integer :perc_quinella_top3

      t.integer :count_exacta_top2
      t.integer :perc_exacta_top2

      t.integer :count_exacta_top3
      t.integer :perc_exacta_top3

      t.integer :count_exacta_top4
      t.integer :perc_exacta_top4

      t.integer :count_trifecta_boxed
      t.integer :perc_trifecta_boxed

      t.integer :count_ff_boxed
      t.integer :perc_ff_boxed

      t.integer :count_top2_placed
      t.integer :perc_top2_placed
    end
  end
end

#1) 1st rank came 1st Exact match of 1st place YES = Top Selection Win
#2) 2nd rank came 1st YES = 2nd Selection Win
#3) 1st rank came Top3 (Top2 for 8- horses races) YES = Top Selection Placed
#4) when top 2 rank came 1 and 2 (any order) - Quinella top 2
#5) when top 3 rank came 1 and 2 (any order) - Quinella top 3
#6) when 1st rank came 1st and 2nd rank came 2nd (exact match) - Exacta top 2
#7) if top two select came 1 and if any top 3 select came 2nd - Exacta top 3
#8) if top two select came 1 and top 4 select came second. See previous bet slip for understanding - Exacta top 4
#9) Top3 rank came Top3 (any order) YES = Top 3 Selection Trifecta Boxed
#10) Top4 rank came Top4 (any order) YES = Top 4 Selection FF boxed
#11) Top2 rank came in Top3 (any order) YES = Top two selections Placed

