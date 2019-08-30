class RaceClassesController < ApplicationController
  before_action :access_deny_in_if_not_an_admin
  before_action :set_race_class, only: [:show, :edit, :update, :destroy]

  # GET /race_classes
  def index
    @race_classes = RaceClass.order(:rank)
  end

  # GET /race_classes/1
  def show
  end

  # GET /race_classes/new
  def new
    @race_class = RaceClass.new
  end

  # GET /race_classes/1/edit
  def edit
  end

  # POST /race_classes
  def create
    @race_class = RaceClass.new(race_class_params)

    if @race_class.save
      redirect_to @race_class, notice: 'Race class was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /race_classes/1
  def update
    if @race_class.update(race_class_params)
      redirect_to @race_class, notice: 'Race class was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /race_classes/1
  def destroy
    @race_class.destroy
    redirect_to race_classes_url, notice: 'Race class was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_race_class
      @race_class = RaceClass.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def race_class_params
      params.require(:race_class).permit(:title, :rank)
    end
end
