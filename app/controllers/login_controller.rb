class LoginController < ApplicationController
  layout 'login'

  def index
    @plans = Plan.active
  end
end
