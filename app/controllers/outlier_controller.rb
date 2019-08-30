class OutlierController < ApplicationController
  before_action :access_deny_in_if_not_an_admin

  def index
    sql = "select t.title,count(*) "
    19.times do |i|
      sql << ",sum(case when outlier#{i+1}>0 then 1 else 0 end)"
    end
    sql << " from races r join tracks t on r.track_id=t.id"
    sql << " join (select r.id from races r join participates p on r.id=p.race_id where start_date>='2018-02-01' and coalesce(finished,'')='1' group by r.id,finished having count(*)=1)x on x.id=r.id"
    sql << " join participates p on r.id=p.race_id and finished='1' join horse_positions hp on hp.race_id=r.id and hp.horse_number=p.horse_number"
    sql << " where start_date>='2018-02-01' group by t.title order by t.title"
    @result =  ActiveRecord::Base.connection.execute(sql).values
  end
end
