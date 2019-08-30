class MainController < ApplicationController
  before_action :access_deny_in_if_not_an_admin
  def index
    sql = "
      select title
      ,round(avg(case finished when 1 then 1 when 2 then 0.75 when 3 then 0.5 else 0.25 end),2)
      ,round(avg(case when margin<=0.5 then 1 when margin<=1 then 0.8 when margin<=2 then 0.5 else 0.25 end),2)
      ,round(avg(score/1000.0),2)
			,round(cast(avg(finished)as decimal),2),round(cast(avg(margin)as decimal),2)
      from (
        select
        p.race_id
        ,t.title||' R'||r.race_number as title
        ,rank() over (partition by p.horse_id order by rx.start_date desc)as no,cast(px.finished as integer)as finished
        ,cast(case when position('L' in px.margin)>0 then substring(px.margin,1,position('L' in px.margin)-1) when px.finished='1' then '0' end as float)as margin
        ,hp.score
        from races r
        join tracks t on r.track_id=t.id
        join participates p on r.id=p.race_id
        join horse_positions hp on p.race_id=hp.race_id and p.horse_number=hp.horse_number and hp.score_position_reordered=1
        join participates px on px.horse_id=p.horse_id and coalesce(px.finished,'')<>'' and (position('L' in px.margin)>0 or px.finished='1')
        join races rx on rx.id=px.race_id and rx.start_date<r.start_date
        where r.start_date='#{get_today}'
      )x
      group by title,race_id
      having count(*)>=5
      order by get_race_class(race_id) desc
      limit 5"
    @dashboard_data = ActiveRecord::Base.connection.execute(sql).values.map{|r| r.join(',')}.join(';')
  end
end
