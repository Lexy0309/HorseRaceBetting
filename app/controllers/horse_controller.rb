class HorseController < ApplicationController
  before_action :access_deny_in_if_not_an_admin
  def show
    begin
      @horse = Horse.find(params[:id])
      @participates = @horse.participates.includes(:jockey,:trainer,race: :track).where('coalesce(scratched,0)=0').order('races.start_date desc')
    rescue
      redirect_to(root_path) && return
    end
  end
end
