class TipsReportController < ApplicationController
  before_action :access_deny_in_if_not_an_admin

  def index
    sql = "select to_char(min(r.start_date),'dd-mm-yyyy'),to_char(max(r.start_date),'dd-mm-yyyy'),count(*)
    ,sum(case when rt1.place1=p1.horse_number then 1 else 0 end)
    ,sum(case when rt1.place2=p1.horse_number then 1 else 0 end)
    ,sum(case when rt1.place1 in (p1.horse_number,p2.horse_number,p3.horse_number,p4.horse_number) then 1 else 0 end)
    ,sum(case when rt2.place1=p1.horse_number then 1 else 0 end)
    ,sum(case when rt2.place2=p1.horse_number then 1 else 0 end)
    ,sum(case when rt2.place1 in (p1.horse_number,p2.horse_number,p3.horse_number,p4.horse_number) then 1 else 0 end)
    ,sum(case when hp1.horse_number=p1.horse_number then 1 else 0 end)
    ,sum(case when hp2.horse_number=p1.horse_number then 1 else 0 end)
    ,sum(case when hp1.horse_number in (p1.horse_number,p2.horse_number,p3.horse_number,p4.horse_number) then 1 else 0 end)
    from races r
    join race_tips rt1 on rt1.race_id=r.id and rt1.source=1
    join race_tips rt2 on rt2.race_id=r.id and rt2.source=2
    join participates p1 on p1.race_id=r.id and p1.finished='1'
    join participates p2 on p2.race_id=r.id and p2.finished='2'
    join participates p3 on p3.race_id=r.id and p3.finished='3'
    join participates p4 on p4.race_id=r.id and p4.finished='4'
    join horse_positions hp1 on hp1.race_id=r.id and hp1.score_position_reordered=1
    join horse_positions hp2 on hp2.race_id=r.id and hp2.score_position_reordered=2"
    @result =  ActiveRecord::Base.connection.execute(sql).values[-1]
  end
end
