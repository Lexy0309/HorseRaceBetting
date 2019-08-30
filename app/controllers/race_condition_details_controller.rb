class RaceConditionDetailsController < ApplicationController
  before_action :access_deny_in_if_not_an_admin
  before_action :set_race_condition_detail, only: [:show, :edit, :update, :destroy]

  # GET /race_condition_details
  def index
    @race_condition_details = RaceConditionDetail.all
  end

  # GET /race_condition_details/1
  def show
  end

  # GET /race_condition_details/new
  def new
    @race_condition_detail = RaceConditionDetail.new
  end

  # GET /race_condition_details/1/edit
  def edit
  end

  # POST /race_condition_details
  def create
    @race_condition_detail = RaceConditionDetail.new(race_condition_detail_params)

    if @race_condition_detail.save
      redirect_to @race_condition_detail, notice: 'Race condition detail was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /race_condition_details/1
  def update
    if @race_condition_detail.update(race_condition_detail_params)
      redirect_to @race_condition_detail, notice: 'Race condition detail was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /race_condition_details/1
  def destroy
    @race_condition_detail.destroy
    redirect_to race_condition_details_url, notice: 'Race condition detail was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_race_condition_detail
      @race_condition_detail = RaceConditionDetail.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def race_condition_detail_params
      params.require(:race_condition_detail).permit(:title, :rank)
    end
end
