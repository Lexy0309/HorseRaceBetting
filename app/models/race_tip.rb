class RaceTip < ApplicationRecord
  belongs_to :race

  def self.sources
    {
        1=> 'racenet',
        2=> 'tab.com'
    }
  end

  def self.stats(start_date)
    sql = "select count(*)
      ,sum(fs_bb),sum(ss_bb),sum(ps_bb)
      ,sum(fs_ta),sum(ss_ta),sum(ps_ta)
      ,sum(fs_ra),sum(ss_ra),sum(ps_ra)
      from (
        select r.id
        ,case p1.horse_number when hp1.horse_number then 1 else 0 end as fs_bb
        ,case p1.horse_number when hp2.horse_number then 1 else 0 end as ss_bb
        ,case when hp1.horse_number in (p1.horse_number,p2.horse_number,p3.horse_number) then 1 else 0 end as ps_bb
        ,case p1.horse_number when rt1.place1 then 1 else 0 end as fs_ra
        ,case p1.horse_number when rt1.place2 then 1 else 0 end as ss_ra
        ,case when rt1.place1 in (p1.horse_number,p2.horse_number,p3.horse_number) then 1 else 0 end as ps_ra
        ,case p1.horse_number when rt2.place1 then 1 else 0 end as fs_ta
        ,case p1.horse_number when rt2.place2 then 1 else 0 end as ss_ta
        ,case when rt2.place1 in (p1.horse_number,p2.horse_number,p3.horse_number) then 1 else 0 end as ps_ta
        from races r
        join participates p1 on r.id=p1.race_id and p1.finished='1'
        join participates p2 on r.id=p2.race_id and p2.finished='2'
        join participates p3 on r.id=p3.race_id and p3.finished='3'
        left join horse_positions hp1 on hp1.race_id=r.id and hp1.score_position_reordered=1
        left join horse_positions hp2 on hp2.race_id=r.id and hp2.score_position_reordered=2
        left join race_tips rt1 on rt1.race_id=r.id and rt1.source=1
        left join race_tips rt2 on rt2.race_id=r.id and rt2.source=2
        where r.start_date='#{start_date}'
      )x"
    data = ActiveRecord::Base.connection.execute(sql).values
  end
end
