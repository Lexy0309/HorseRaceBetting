class ScorecardController < ApplicationController
  before_action :access_deny_in_if_not_an_admin
  def index
    @scorecards = Scorecard.where(track_id:0).order('start_date desc')
  end

  def show
  end

  def date
    allowed_params = params.permit(:start_date)
    @start_date = allowed_params[:start_date]
    @scorecards = Scorecard.where(start_date:@start_date).where('scorecards.track_id<>0').includes(:track).order('tracks.title')
    races = Race.where(start_date:@start_date,race_number:1)
    @races = {}
    races.each do |race|
      @races[race.track_id] = race.id
    end
  end

  def total
    sql = 'select title,t.id,sum(total_races),sum(count_top_selection),round((sum(count_top_selection)+0.0)/sum(total_races),2) from scorecards s join tracks t on s.track_id=t.id where track_id>0 group by title,t.id order by 3 desc'
    @result =  ActiveRecord::Base.connection.execute(sql).values
  end

  def graph
    @tracks = Track.includes(track_detail: :state).order(:title)
    @states = State.order(:title)
  end

  def api
    allowed_params = params.permit(:type,:year,:state,:track,:bet_types)
    year = [2017,2018,0].include?(allowed_params[:year].to_i) ? allowed_params[:year].to_i : 0
    type = %w[month day week].include?(allowed_params[:type]) ? allowed_params[:type] : 'day'
    state_id = allowed_params[:state].to_i
    track_id = allowed_params[:track].to_i
    bet_types = allowed_params[:bet_types].to_s.split(',').select{|bet| Scorecard.field_list.include? bet}
    bet_types = bet_types.blank? ? Scorecard.field_list : bet_types
    if type=='day'
      sql_part = 'extract(isodow from start_date)-1'
    elsif type=='month'
      sql_part = "date_part('month',start_date)-1"
    elsif type=='week'
      sql_part = "case when date_part('day',start_date) <=7 then 1 when date_part('day',start_date) <=14 then 2 when date_part('day',start_date) <=21 then 3 when date_part('day',start_date) <=28 then 4 else 5 end"
    end
    sql = "select #{sql_part}
,round(avg(perc_top_selection),2)
,round(avg(perc_2nd_selection),2)
,round(avg(perc_top_selection_placed),2)
,round(avg(perc_quinella_top2),2)
,round(avg(perc_quinella_top3),2)
,round(avg(perc_exacta_top2),2)
,round(avg(perc_exacta_top3),2)
,round(avg(perc_exacta_top4),2)
,round(avg(perc_trifecta_boxed),2)
,round(avg(perc_ff_boxed),2)
,round(avg(perc_top2_placed),2)
,round(avg(perc_machine_learning),2)
from scorecards s
left join track_details td on td.track_id=s.track_id
where 1=1 #{track_id.zero? ? (state_id.zero? ? ' and s.track_id=0' : " and td.state_id=#{state_id} ") : " and s.track_id=#{track_id} "}
#{year.zero? ? '' : " and start_date between '#{year}-01-01' and '#{year}-12-31'"}
group by #{sql_part} order by 1"
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
        elem[bet_type] = row[Scorecard.field_list.index(bet_type)+1].to_f
      end
      result << elem
    end
    render json: {fields: bet_types.map{|b| {title: RacePool.capitalize_special(b),special: b}},data: result}.as_json
  end
end
