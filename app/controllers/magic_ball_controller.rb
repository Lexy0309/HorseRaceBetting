class MagicBallController < ApplicationController
  require 'magic_eightball_lib'

  before_action :access_deny_in_if_not_a_user
  before_action :check_has_access_to_magic_ball

  def index

  end

  def tool

  end

  def api
    allowed_params = params.permit(:start_date,:timestamp,:full)
    begin
      start_date = allowed_params[:start_date]
      start_date = DateTime.strptime(start_date,'%Y-%m-%d').strftime('%Y-%m-%d')
    rescue
      start_date = get_today
    end
    timestamp = allowed_params[:timestamp].to_i.zero? ? Time.now.to_i : allowed_params[:timestamp].to_i
    full = allowed_params[:full].to_i
    result = MagicEightball.process_eightball(start_date,timestamp)
    if full.zero?
      render(json: {data: result[:data]}) && return
    else
      render(json: result) && return
    end
  end

  def show
    @start_date = params[:id]
    @frames = MagicBallFrame.includes(winner: :track,races: :track).where(start_date:@start_date).order(:frame_start)
    if @frames.blank?
      redirect_to(magic_ball_index_path) && return
    end
  end

  private

  def check_has_access_to_magic_ball
    redirect_to plans_path unless (current_user.has_third_tier? || current_user.has_first_tier?)
  end
end
