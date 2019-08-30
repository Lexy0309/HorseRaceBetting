class Scorecard < ApplicationRecord
  belongs_to :track
  def self.field_list
    %w[top_selection 2nd_selection top_selection_placed quinella_top2 quinella_top3 exacta_top2 exacta_top3 exacta_top4 trifecta_boxed ff_boxed top2_placed machine_learning magic_ball]
  end

  def self.daily_top(date,limit=5)
    sql = "select t.title,x.title,x.value from tracks t join ("
    sql << " select distinct track_id,perc_top_selection as value,'Top selection' as title from scorecards where coalesce(track_id,0)>0 union"
    sql << " select distinct track_id,perc_quinella_top2 as value,'Quinella top 2' as title from scorecards where coalesce(track_id,0)>0 union"
    sql << " select distinct track_id,perc_exacta_top4 as value,'Exacta top 4' as title from scorecards where coalesce(track_id,0)>0"
    sql << " )x on x.track_id=t.id where t.id in (select track_id from races where start_date='#{date}') order by x.value desc limit #{limit}"
    ActiveRecord::Base.connection.execute(sql).values
  end
end