class GorillaBetsController < ApplicationController
  before_action :access_deny_in_if_not_a_user
  before_action :check_has_access_to_gorilla_bets

  def index
    @today_bets = Bet.includes(bet_races: [:bet_horses, race: :track]).where(start_date:get_today_daily).order(:category)
  end

  def by_week_special
    allowed_params = params.permit(:weekdays)
    weekdays_default = [1,2,3,4,5,6,7]
    weekdays = allowed_params[:weekdays].to_s
    weekdays = weekdays.split(',').uniq.map(&:to_i).select{|wd| (1..7).include?(wd)}.sort
    weekdays = weekdays.blank? ? weekdays_default : weekdays
    start_date = current_user.created_at
    sql = "select cast('#{start_date}'as date)+(ceil((start_date-cast('#{start_date}'as date)+1)/7.0)-1)*7*interval ' 1day'
    ,ceil((start_date-cast('#{start_date}'as date)+1)/7.0),sum(amount),sum(reward),sum(reward-amount)
    from bets
    where start_date>='#{start_date}' and case extract(dow from start_date) when 0 then 7 else extract(dow from start_date) end in (#{weekdays.join(',')})
    group by ceil((start_date-cast('#{start_date}'as date)+1)/7.0)
    order by 1"
    weeks = ActiveRecord::Base.connection.execute(sql).values
    render(json: {data:weeks,graph_data:weeks.map{|row| {title:row[1],amount:row[2].to_f,reward:row[3].to_f}}})
  end

  private

  def check_has_access_to_gorilla_bets
    redirect_to plans_path unless (current_user.has_second_tier? || current_user.is_admin?)
  end
end
