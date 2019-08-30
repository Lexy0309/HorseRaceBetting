class ScoreReportController < ApplicationController
  before_action :access_deny_in_if_not_an_admin
  def index
    @score_count = 10
    allowed_params = params.permit(:date,:track_id)
    @date = allowed_params[:date].to_s.gsub("'","''")
    @track_id = allowed_params[:track_id].to_i
    if @track_id>0
      sql = " select t.title,count(*),#{@score_count.times.map{|i| "count(h#{i+1}.id)as score#{i+1}"}.join(',')},min(r.id) as race_id"
      sql << ' from races r join tracks t on r.track_id=t.id '
      sql << " join (select p.race_id,#{@score_count.times.map{|i| "max(score#{i+1})as score#{i+1}"}.join(',')} from participates p join horse_positions h on h.race_id=p.race_id and h.horse_number=p.horse_number"
      sql << " join races r on p.race_id=r.id and r.track_id=#{@track_id} group by p.race_id)rs on rs.race_id=r.id "
      @score_count.times.each do |i|
        n = i + 1
        sql << " left join participates p#{n} on r.id=p#{n}.race_id and p#{n}.finished='#{n}'"
        sql << " left join horse_positions h#{n} on r.id=h#{n}.race_id and h#{n}.score#{n}=rs.score#{n} and h#{n}.horse_number=p#{n}.horse_number"
      end
      sql << " where r.track_id=#{@track_id} and start_date>'2018-02-01' group by t.title order by t.title"
      @result =  ActiveRecord::Base.connection.execute(sql).values
    elsif @date.blank?
      sql = "select start_date from races r join participates p on r.id=p.race_id join horse_positions h on h.race_id=p.race_id and h.horse_number=p.horse_number where start_date>'2018-02-01' and coalesce(score_position,0)<>0 and coalesce(finished,'')<>'' group by start_date order by start_date desc"
      @dates = ActiveRecord::Base.connection.execute(sql).values.map{|row| row[0]}
    else
      sql = " select t.title,count(*),#{@score_count.times.map{|i| "count(h#{i+1}.id)as score#{i+1}"}.join(',')},min(r.id) as race_id"
      sql << ' from races r join tracks t on r.track_id=t.id '
      sql << " join (select p.race_id,#{@score_count.times.map{|i| "max(score#{i+1})as score#{i+1}"}.join(',')} from participates p join horse_positions h on h.race_id=p.race_id and h.horse_number=p.horse_number join races r on p.race_id=r.id and r.start_date='#{@date}' group by p.race_id)rs on rs.race_id=r.id "
      @score_count.times.each do |i|
        n = i + 1
        sql << " left join participates p#{n} on r.id=p#{n}.race_id and p#{n}.finished='#{n}'"
        sql << " left join horse_positions h#{n} on r.id=h#{n}.race_id and h#{n}.score#{n}=rs.score#{n} and h#{n}.horse_number=p#{n}.horse_number"
      end
      sql << " where r.start_date ='#{@date}' group by t.title order by t.title"
      @result =  ActiveRecord::Base.connection.execute(sql).values
    end
  end

end
