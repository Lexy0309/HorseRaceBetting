class UpcomingFeatureRacesController < ApplicationController
  before_action :access_deny_in_if_not_a_user

  def index
    @group_races = GroupRace.where("start_date between '#{get_today}' and '#{get_today(30)}'")
  end
end
