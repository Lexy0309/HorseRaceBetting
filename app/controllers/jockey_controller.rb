class JockeyController < ApplicationController
  before_action :access_deny_in_if_not_an_admin
  def show
    begin
      @jockey = Jockey.find(params[:id])
      @participates = @jockey.participates.includes(:trainer,:horse,race: :track).where('coalesce(scratched,0)=0').order('races.start_date desc')
    rescue
      redirect_to(root_path) && return
    end
  end
end
