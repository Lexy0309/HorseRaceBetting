class DailyTipsController < ApplicationController
  before_action :access_deny_in_if_not_a_user
  before_action :force_user_to_fill_in_info

  def index
    track_ids = Race.where(start_date:get_today_daily).map(&:track_id).uniq
    @states = Track.where(id:track_ids).includes(track_detail: :state).order('states.title').map do |track|
      {title: track.track_detail.state.title, id:track.track_detail.state.id}
    end.uniq

    races = Race.where(start_date: get_today_daily).includes(:track).includes(horse_positions: :horse)
    @data = {tracks:{}}
    races.each do |race|
      if @data[:tracks].include?(race.track_id)
        @data[:tracks][race.track_id][:races][race.id] = {race_number: race.race_number, horses: {}}
      else
        @data[:tracks][race.track_id] = {title: race.track.title,races:{race.id=> {race_number: race.race_number, horses: {}}}}
      end
      race.horse_positions.each do |hp|
        if (1..4).include? hp.score_position_reordered
          @data[:tracks][race.track_id][:races][race.id][:horses][hp.horse_number] = {rank: hp.score_position_reordered,title:hp.horse.title}
        end
      end
    end
    ParticipateDetail.where(race_id: races.map(&:id)).includes(:race).each do |pd|
      if  @data[:tracks][pd.race.track_id][:races][pd.race_id][:horses].include? pd.horse_number
        @data[:tracks][pd.race.track_id][:races][pd.race_id][:horses][pd.horse_number][:win] = pd.fixed_odd_win.blank? ? '' : "$#{pd.fixed_odd_win}"
        @data[:tracks][pd.race.track_id][:races][pd.race_id][:horses][pd.horse_number][:place] = pd.fixed_odd_place.blank? ? '' : "$#{pd.fixed_odd_place}"
      end
    end
    if user_signed_in?
      current_user.process_ip_address
    end
    @quaddies = Bet.where(category:2,start_date:get_today_daily).includes(bet_races: [:bet_horses, race: :track])
    @track_top_perfomance_data = Track.get_top_perfomance_data(get_today_daily)
    @top_performing_horse = Track.get_top_performing_horse(get_today_daily)
    @top_performing_jockey = Track.get_top_performing_jockey(get_today_daily)
    @top_price_in_best_class_data = Track.get_top_price_in_best_class_data(get_today_daily)
  end

  def tracks
    state_id = params[:state_id]
    allowed_tracks = Track.includes(:track_detail).where('track_details.state_id':state_id).map{|track| track.id}
    @tracks = Race.where(start_date:get_today_daily,track_id:allowed_tracks).includes(:track).map do |race|
      {title:race.track.title,id:race.track.code}
    end.uniq.sort_by{|track| track[:title]}
    render('daily_tips/tracks', layout: false)
  end

  def races
    track_code = params[:track_id].to_s
    tracks_raw = Track.where(code: track_code)
    if tracks_raw.size>0
      track_ids = tracks_raw.map(&:id)
      races = Race.where(start_date: get_today_daily,track_id: track_ids).includes(:track).includes(horse_positions: :horse)
      unless races.blank?
        @data = {title: races[0].track.title,races:{},track: races[0].track.title}
        race_ids = races.map(&:id)
        races.each do |race|
          @data[:races][race.id] = {race_number: race.race_number, horses: {},exacta: 0, trifecta: 0, ff: 0}
          others = []
          race.horse_positions.each do |hp|
            if (1..4).include? hp.score_position_reordered
              @data[:races][race.id][:horses][hp.horse_number] = {rank: hp.score_position_reordered,title:hp.horse.title,id:hp.id}
            elsif (5..7).include? hp.score_position_reordered
              others << hp.horse_number
            end
          end
          @data[:races][race.id][:others] = "First four numbers #{others.join(',')}"
        end
        ParticipateDetail.where(race_id: race_ids).each do |pd|
          if @data[:races][pd.race_id][:horses].include? pd.horse_number
            @data[:races][pd.race_id][:horses][pd.horse_number][:win] = pd.fixed_odd_win.blank? ? '' : "$#{pd.fixed_odd_win}"
            @data[:races][pd.race_id][:horses][pd.horse_number][:win_tick] = (pd.position==1 && [1,2,3,4].include?(@data[:races][pd.race_id][:horses][pd.horse_number][:rank]))
            @data[:races][pd.race_id][:horses][pd.horse_number][:place] = pd.fixed_odd_place.blank? ? '' : "$#{pd.fixed_odd_place}"
            @data[:races][pd.race_id][:horses][pd.horse_number][:place_tick] = [1,2,3,4].include?(pd.position.to_i)
            @data[:races][pd.race_id][:horses][pd.horse_number][:position] = pd.position.to_i

            if pd.position.to_i>0
              @data[:races][pd.race_id][:ff] += 1
            end
            if [1,2].include? pd.position.to_i
              @data[:races][pd.race_id][:exacta] += 1
            end
            if [1,2,3].include?(pd.position.to_i) && [1,2,3].include?(@data[:races][pd.race_id][:horses][pd.horse_number][:rank].to_i)
              @data[:races][pd.race_id][:trifecta] += 1
            end

            @data[:races][pd.race_id][:horses][pd.horse_number][:exacta] = pd.exacta.blank? ? '' : "$#{pd.exacta}"
            @data[:races][pd.race_id][:horses][pd.horse_number][:trifecta] = pd.trifecta.blank? ? '' : "$#{pd.trifecta}"
            @data[:races][pd.race_id][:horses][pd.horse_number][:ff] = pd.first_four.blank? ? '' : "$#{pd.first_four}"
          end
        end
        @class_strength_data = Race.get_class_strength(get_today_daily)
        @prediction_strength_data = Race.get_prediction_strength(get_today_daily)
      end
    end
    render('daily_tips/races', layout: false)
  end

  def tips
    raw_date = params[:date].to_s
    date = Date.strptime(get_today(-1),'%Y-%m-%d')
    begin
      date = Date.strptime(raw_date,'%Y-%m-%d')
    rescue
    end
    if date<Date.strptime(get_today,'%Y-%m-%d')
      sql = "select count(*)
        ,sum(fs_bb),round(avg(ap_bb),2),sum(ss_bb),sum(ps_bb)
        ,sum(fs_ta),round(avg(ap_ta),2),sum(ss_ta),sum(ps_ta)
        ,sum(fs_ra),round(avg(ap_ra),2),sum(ss_ra),sum(ps_ra)
        from (
          select r.id
					,case p1.horse_number when hp1.horse_number then pd.fixed_odd_win end as ap_bb
          ,case p1.horse_number when hp1.horse_number then 1 else 0 end as fs_bb
          ,case p1.horse_number when hp2.horse_number then 1 else 0 end as ss_bb
          ,case when hp1.horse_number in (p1.horse_number,p2.horse_number,p3.horse_number) then 1 else 0 end as ps_bb
					,case p1.horse_number when rt1.place1 then pd.fixed_odd_win end as ap_ra
          ,case p1.horse_number when rt1.place1 then 1 else 0 end as fs_ra
          ,case p1.horse_number when rt1.place2 then 1 else 0 end as ss_ra
          ,case when rt1.place1 in (p1.horse_number,p2.horse_number,p3.horse_number) then 1 else 0 end as ps_ra
          ,case p1.horse_number when rt2.place1 then pd.fixed_odd_win end as ap_ta
					,case p1.horse_number when rt2.place1 then 1 else 0 end as fs_ta
          ,case p1.horse_number when rt2.place2 then 1 else 0 end as ss_ta
          ,case when rt2.place1 in (p1.horse_number,p2.horse_number,p3.horse_number) then 1 else 0 end as ps_ta
          from races r
          join participates p1 on r.id=p1.race_id and p1.finished='1'
          join participates p2 on r.id=p2.race_id and p2.finished='2'
          join participates p3 on r.id=p3.race_id and p3.finished='3'
					left join participate_details pd on r.id=pd.race_id and p1.horse_number=pd.horse_number
          left join horse_positions hp1 on hp1.race_id=r.id and hp1.score_position_reordered=1
          left join horse_positions hp2 on hp2.race_id=r.id and hp2.score_position_reordered=2
          left join race_tips rt1 on rt1.race_id=r.id and rt1.source=1
          left join race_tips rt2 on rt2.race_id=r.id and rt2.source=2
          where r.start_date='#{date}'
      )x;"
      @data = ActiveRecord::Base.connection.execute(sql).values[0]
    end
    render('daily_tips/tips',layout: false)
  end
end

