class DateController < ApplicationController
  before_action :access_deny_in_if_not_an_admin
  def show
    raw_date = params[:id]
    if raw_date=='today'
      raw_date = get_today
    end
    races = Race.includes(:track).where(start_date:raw_date)
    if races.any?
      @tracks = races.map{|r| r.track}.uniq.sort_by{|t| t.title}
      @max_race_number = races.map{|r| r.race_number}.max
      @data = {}
      races.each do |race|
        if @data.include?(race.track_id)
          @data[race.track_id][race.race_number] = race
        else
          @data[race.track_id] = {race.race_number=> race}
        end
      end
    end
    begin
      date = DateTime.strptime(raw_date,'%Y-%m-%d')
      @tomorrow,@yesterday = [1,-1].map{|delta| (date+delta).strftime('%Y-%m-%d')}
    rescue
    end
    @bets = Bet.includes(bet_races: [:bet_horses, {race: :track}]).where(start_date:raw_date).order(:category)
  end

  def index
    sql = 'select category,count(*),sum(amount),sum(reward) from bets group by category order by category'
    @data = ActiveRecord::Base.connection.execute(sql).values
  end
end