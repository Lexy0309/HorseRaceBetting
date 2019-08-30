class SummaryController < ApplicationController
  before_action :access_deny_in_if_not_an_admin

  def show
    raw_date = params[:id]
    if raw_date=='today'
      start_date = get_today()
    elsif raw_date=='tomorrow'
      start_date = get_today(1)
    else
      start_date = raw_date
    end
    races = Race.where(start_date: start_date).includes(:track).includes(horse_positions: :horse)
    unless races.any?
      redirect_to(root_path) && return
    end
    @date = raw_date
    @data = {}
    races.each do |race|
      unless @data.include? race.track_id
        @data[race.track_id] = {title:race.track.title,races:{},rail:race.rail}
      end
    end
    track_by_race = {}
    races.each do |race|
      track_by_race[race.id] = race.track_id
      @data[race.track_id][:races][race.id] = {race_number:race.race_number,horses:{}}
      race.horse_positions.each do |hp|
        if (1..4).include? hp.score_position_reordered
          @data[race.track_id][:races][race.id][:horses][hp.horse_number] = {title: hp.horse.title,score_position:hp.score_position_reordered,result:0}
        end
      end
    end
    ParticipateDetail.where(race_id:races.map(&:id)).each do |pd|
      race_id = pd.race_id
      track_id = track_by_race[race_id]
      unless track_id.nil?
        unless pd.exacta.to_f.zero?
          @data[track_id][:races][race_id][:exacta] = pd.exacta
        end
        if @data[track_id][:races][race_id][:horses].include? pd.horse_number
          @data[track_id][:races][race_id][:horses][pd.horse_number][:win] = pd.fixed_odd_win.to_i.zero? ? '' : "$#{pd.fixed_odd_win}"
          @data[track_id][:races][race_id][:horses][pd.horse_number][:place] = pd.fixed_odd_place.to_i.zero? ? '' : "$#{pd.fixed_odd_place}"
          @data[track_id][:races][race_id][:horses][pd.horse_number][:result] = pd.position.to_i
        end
      end
    end
    Participate.where(race_id:races.map(&:id)).each do |p|
      race_id = p.race_id
      track_id = track_by_race[race_id]
      unless track_id.nil?
        if @data[track_id][:races][race_id][:horses].include? p.horse_number
          unless p.finished.to_i.zero?
            @data[track_id][:races][race_id][:horses][p.horse_number][:result] = p.finished.to_i
          end
        end
      end
    end
    @data.values.each do |track|
      track[:races].values.each do |race|
        results = {}
        race[:horses].values.each do |horse|
          results[horse[:score_position]] = horse[:result]
        end
        race[:exacta2] = [1,2].map{|x| [1,2].include?(results[x]) ? 1 : 0}.reduce(0){|sum,x| sum+x.to_i}==2 ? race[:exacta] : 0
        race[:exacta3] = [1,2,3].map{|x| [1,2].include?(results[x]) ? 1 : 0}.reduce(0){|sum,x| sum+x.to_i}==2 ? race[:exacta] : 0
        race[:exacta4] = [1,2,3,4].map{|x| [1,2].include?(results[x]) ? 1 : 0}.reduce(0){|sum,x| sum+x.to_i}==2 ? race[:exacta] : 0
      end
    end
    p @data



    @tracks = races.map(&:track).uniq
    @races = {}
    races.map do |r|
      if @races.include?(r.track_id)
        @races[r.track_id] << r
      else
        @races[r.track_id] = [r]
      end
    end
    @horses = {}


    @details = {}
    ParticipateDetail.where(race_id:races.map(&:id)).each do |pd|
      obj = {win: pd.fixed_odd_win, place: pd.fixed_odd_place,position:pd.position}
      if @details.include?(pd.race_id)
        @details[pd.race_id][pd.horse_number] = obj
      else
        @details[pd.race_id] = {pd.horse_number=>obj}
      end
    end
    @participates = {}
    Participate.where(race_id:races.map(&:id)).each do |p|
      if p.scratched.to_i.zero?
        if @participates.include?(p.race_id)
          @participates[p.race_id][p.horse_number] = p
        else
          @participates[p.race_id] = {p.horse_number=>p}
        end
      end
    end

  end
end
