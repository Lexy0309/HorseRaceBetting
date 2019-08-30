class PoolController < ApplicationController
  before_action :access_deny_in_if_not_an_admin

  def index
    @tracks = Track.includes(track_detail: :state).order(:title)
    @states = State.order(:title)
  end

  def api
    allowed_params = params.permit(:type,:year,:state,:track,:bet_types)
    year = [2017,2018].include?(allowed_params[:year].to_i) ? allowed_params[:year].to_i : 0
    type = %w[month day week].include?(allowed_params[:type]) ? allowed_params[:type] : 'day'
    state_id = allowed_params[:state].to_i
    track_id = allowed_params[:track].to_i
    bet_types = allowed_params[:bet_types].to_s.split(',').select{|bet| RacePool::BET_TITLES.include? bet}
    bet_types = bet_types.blank? ? RacePool::BET_TITLES : bet_types
    sql_part = ',round(avg(p.win),2),round(avg(p.place),2),round(avg(p.quinella),2),round(avg(p.exacta),2),round(avg(p.duet),2),round(avg(p.trifecta),2)
,round(avg(p.first_four),2),round(avg(p.running_double),2),round(avg(p.daily_double),2),round(avg(p.early_quaddie),2),round(avg(p.quaddie),2),round(avg(p.big_6),2)
from race_pools p
join races r on r.id=p.race_id'
    if track_id>0
      sql_part << " and r.track_id=#{track_id}"
    elsif state_id>0
      sql_part << " join track_details td on td.track_id=r.track_id and td.state_id=#{state_id}"
    end
    unless year.zero?
      sql_part << " where r.start_date between '#{year}-01-01' and '#{year}-12-31'"
    end
    if type=='day'
      sql = "select extract(isodow from r.start_date)-1
#{sql_part}
group by extract(isodow from r.start_date)-1
order by 1"
    elsif type=='month'
      sql = "select date_part('month',r.start_date) - 1
#{sql_part}
group by date_part('month',r.start_date) - 1
order by 1"
    elsif type=='week'
      sql = "select case when date_part('day',r.start_date) <=7 then 1 when date_part('day',r.start_date) <=14 then 2 when date_part('day',r.start_date) <=21 then 3 when date_part('day',r.start_date) <=28 then 4 else 5 end
#{sql_part}
group by case when date_part('day',r.start_date) <=7 then 1 when date_part('day',r.start_date) <=14 then 2 when date_part('day',r.start_date) <=21 then 3 when date_part('day',r.start_date) <=28 then 4 else 5 end
order by 1"
    end
    result = []
    values = ActiveRecord::Base.connection.execute(sql).values
    values.each do |row|
      elem = {}
      if type=='day'
        elem['title'] = %w[Monday Tuesday Wednesday Thursday Friday Saturday Sunday][row[0]]
      elsif type=='month'
        elem['title'] = %w[Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec][row[0]]
      elsif type=='week'
        elem['title'] = "Week #{row[0]}"
      end
      bet_types.each do |bet_type|
        elem[bet_type] = row[RacePool::BET_TITLES.index(bet_type)+1].to_f
      end
      result << elem
    end
    render json: {fields: bet_types.map{|b| {title: RacePool.capitalize_special(b),special: b}},data: result}.as_json
  end
end
