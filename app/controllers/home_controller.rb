class HomeController < ApplicationController
  layout 'home'

  def index
    @plans = Plan.active
  end
end
