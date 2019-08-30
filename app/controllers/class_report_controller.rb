class ClassReportController < ApplicationController
  before_action :access_deny_in_if_not_an_admin

  def index
    @score_count = 10
    sql = 'select c.rank,count(*)'
    @score_count.times.each do |i|
      sql << ",sum(case when hp.score#{i+1}=rs.s#{i+1} and rs.s#{i+1}<>0 then 1 else 0 end)"
      sql << ",round(sum(case when hp.score#{i+1}=rs.s#{i+1} and rs.s#{i+1}<>0 then 1 else 0 end)/(count(*)+0.0)*100)||'%'"
    end
    sql << " from races r join participates p on r.id=p.race_id and p.finished='1' join horse_positions hp on hp.race_id=r.id and hp.horse_number=p.horse_number"
    sql << ' join race_tabs t on r.id=t.race_id join race_classes c on t.race_class=c.title'
    sql << " join (select race_id#{@score_count.times.map{|i| ",max(score#{i+1})as s#{i+1}"}.join('')} from horse_positions group by race_id)rs on rs.race_id=r.id"
    sql << " where start_date>='2018-02-01' group by c.rank order by c.rank"
    p sql
    @result =  ActiveRecord::Base.connection.execute(sql).values
  end
end
