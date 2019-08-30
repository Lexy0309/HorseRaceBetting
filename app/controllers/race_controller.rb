class RaceController < ApplicationController
  before_action :access_deny_in_if_not_an_admin
  def show
    begin
      @race = Race.find(params[:id])
    rescue
      redirect_to(root_path) && return
    end
  end

  def cup
    @races = Race.where("distance=3200 and track_id=205 and date_part('month', start_date)=11")
  end
end
