class ScoreWayController < ApplicationController
  before_action :access_deny_in_if_not_an_admin

  def index
    @score_ways = ScoreWay.order('count desc')
  end
end
