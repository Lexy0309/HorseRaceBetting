class TrainerController < ApplicationController
  before_action :access_deny_in_if_not_an_admin
  def show
    begin
      @trainer = Trainer.find(params[:id])
      @participates = @trainer.participates.includes(:jockey,:horse,race: :track).where('coalesce(scratched,0)=0').order('races.start_date desc')
    rescue
      redirect_to(root_path) && return
    end
  end
end
