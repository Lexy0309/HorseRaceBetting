class RailDetailRanksController < ApplicationController
  before_action :access_deny_in_if_not_an_admin
  before_action :set_rail_detail_rank, only: [:show, :edit, :update, :destroy]

  # GET /rail_detail_ranks
  def index
    @rail_detail_ranks = RailDetailRank.all
  end

  # GET /rail_detail_ranks/1
  def show
  end

  # GET /rail_detail_ranks/new
  def new
    @rail_detail_rank = RailDetailRank.new
  end

  # GET /rail_detail_ranks/1/edit
  def edit
  end

  # POST /rail_detail_ranks
  def create
    @rail_detail_rank = RailDetailRank.new(rail_detail_rank_params)

    if @rail_detail_rank.save
      redirect_to @rail_detail_rank, notice: 'Rail detail rank was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /rail_detail_ranks/1
  def update
    if @rail_detail_rank.update(rail_detail_rank_params)
      redirect_to @rail_detail_rank, notice: 'Rail detail rank was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /rail_detail_ranks/1
  def destroy
    @rail_detail_rank.destroy
    redirect_to rail_detail_ranks_url, notice: 'Rail detail rank was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_rail_detail_rank
      @rail_detail_rank = RailDetailRank.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def rail_detail_rank_params
      params.require(:rail_detail_rank).permit(:title, :rank)
    end
end
