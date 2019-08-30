class Track < ApplicationRecord
  has_many :races
  has_one :track_detail
  has_many :scorecards
  has_one :track_stat
  belongs_to :horse
  belongs_to :jockey

  def self.get_top_perfomance_data(date)
    sql = "select t.title,t.id,t.average_daily_winrate,t.best_daily_winrate
from races r
join tracks t on t.id=r.track_id
where r.start_date='#{date}'
group by t.title,t.id,t.average_daily_winrate,t.best_daily_winrate
order by t.average_daily_winrate desc,t.best_daily_winrate desc
limit 3"
    ActiveRecord::Base.connection.execute(sql).values
  end

  def self.get_top_performing_horse(date)
    sql = "select t.title||' R'||r.race_number,h.title,t.horse_winrate
from races r
join tracks t on r.track_id=t.id
join participates p on r.id=p.race_id and t.horse_id=p.horse_id
join horses h on h.id=p.horse_id
where r.start_date='#{date}'
order by t.horse_winrate desc,h.title
limit 1"
    ActiveRecord::Base.connection.execute(sql).values
  end

  def self.get_top_performing_jockey(date)
    sql = "select t.title,j.title,t.jockey_winrate
from races r
join tracks t on t.id=r.track_id
join jockeys j on t.jockey_id=j.id
where r.start_date='#{date}'
order by t.jockey_winrate desc
limit 1"
    ActiveRecord::Base.connection.execute(sql).values
  end

  def self.get_top_price_in_best_class_data(date)
    sql = "select track_title,title,fixed_odd_win
from (
	select t.title||' R'||r.race_number as track_title
  ,r.id,h.title,pd.fixed_odd_win,rank() over (order by rc.rank desc,r.id)as race_no,rank() over (partition by r.id order by pd.fixed_odd_win desc)as horse_no
	from races r
  join tracks t on r.track_id=t.id
	join participates p on p.race_id=r.id and coalesce(p.scratched,0)=0
	join participate_details pd on pd.race_id=r.id and pd.horse_number=p.horse_number
  join horse_positions hp on hp.race_id=r.id and hp.horse_number=p.horse_number and hp.score_position_reordered in (1,2)
	join horses h on h.id=p.horse_id
	join race_tabs rt on rt.race_id=r.id
	join race_classes rc on rc.title=rt.race_class
	where r.start_date='#{date}' and rc.rank>=150
)x where race_no=1 and horse_no=1"
    ActiveRecord::Base.connection.execute(sql).values
  end
end
