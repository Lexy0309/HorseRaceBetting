class ForecastController < ApplicationController
  before_action :access_deny_in_if_not_an_admin
  def index

  end

  def ajax
    allowed_params = params.permit(:key,:date,:state_id,:track_id,:race_id,:order)
    key = allowed_params[:key]
    date = allowed_params[:date]
    order = allowed_params[:order].to_i
    if date=='tomorrow'
      start_date = get_today(1)
    elsif check_date(date)
      start_date = date
    else
      start_date = get_today()
    end
    state_id = allowed_params[:state_id].to_i
    track_id = allowed_params[:track_id].to_i
    race_id = allowed_params[:race_id].to_i
    if key=='states'
      track_ids = Race.where(start_date:start_date).map{|race| race.track_id}.uniq
      states = Track.where(id:track_ids).includes(track_detail: :state).order('states.title').map do |track|
        {title: track.track_detail.state.title, id:track.track_detail.state.id}
      end.uniq
      render(json:states.as_json)
    elsif key=='tracks'
      tracks = Race.includes(:track).where(start_date:start_date).map{|r| {text:r.track.title,value:r.track_id}}.uniq.sort_by{|x| x[:text]}
      render(json:tracks.as_json)
    elsif key=='tracks_new'
      allowed_tracks = Track.includes(:track_detail).where('track_details.state_id':state_id).map{|track| track.id}
      tracks = Race.where(start_date:start_date,track_id:allowed_tracks).includes(:track).map do |race|
        {title:race.track.title,id:race.track_id}
      end.uniq.sort_by{|track| track[:title]}
      render(json:tracks.as_json)
    elsif key=='races'
      races = Race.where(start_date:start_date,track_id:track_id).order(:race_number).map{|r| {value:r.id,text:"R#{r.race_number} #{r.title}"}}
      render(json:races.as_json)
    elsif key=='races_new'
      race_results = {}
      sql = "select r.id,pd.horse_number,case when hp.score_position=1 and pd.position in (1,2,3,4) then 1 else
	      case when pd.position in (1,2,3,4) and rp.ml_top=pd.horse_number then 2 else 0 end end as win
        from races r
        join participate_details pd on pd.race_id=r.id and coalesce(pd.position,0)>0
        left join horse_positions hp on hp.race_id=r.id and hp.horse_number=pd.horse_number
				left join race_positions rp on rp.race_id=r.id
        where r.track_id=#{track_id} and r.start_date='#{start_date}' order by r.id,pd.position"
      ActiveRecord::Base.connection.execute(sql).values.each do |row|
        race_id = row[0]
        obj = {number:row[1],win:row[2]}
        if race_results.include?(race_id)
          race_results[race_id] << obj
        else
          race_results[race_id] = [obj]
        end
      end
      races = Race.where(start_date:start_date,track_id:track_id).order(:race_number).map do |r|
        race_obj = {id:r.id,title:"R#{r.race_number}"}
        if race_results.include?(r.id)
          race_obj[:results] = race_results[r.id]
        else
          race_obj[:results] = []
        end
        race_obj
      end
      render(json:races.as_json)
    elsif key=='race'
      json_result = {block:[],horses:[]}
      begin
        race = Race.includes(:track,:horse,:jockey).find(race_id)
      rescue
        render(json:json_result.as_json) && return
      end
      unless check_date(race.start_date.strftime('%Y-%m-%d'))
        render(json:json_result.as_json) && return
      end
      positions =race.top_horses.map do |hp|
        {id:hp.horse_id,data:{rank:hp.score_position.ordinalize,runner:"#{hp.horse_number}. #{hp.horse.title}",race:"#{race.track.title} R#{race.race_number} #{race.start_date}"}}
      end
      json_result[:score_fields] = race.score_fields_list
      json_result[:ml_top] = race.ml_top
      json_result[:block] = race.get_block
      json_result[:info] = race.get_info
      json_result[:horses] = race.participates_js(order)
      json_result[:positions] = positions
      json_result[:bets] = race.get_bet_block
      json_result[:places] = race.get_place_block
      json_result[:summary] = race.get_summary
      render(json:json_result.as_json)
    else
      render(json:json_result.as_json)
    end
  end
end