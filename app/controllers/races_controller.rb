class RacesController < ApplicationController
  load_and_authorize_resource
  before_action :set_race, only: [:destroy, :update]

  def create
    @race = Race.new(race_params)
    if @race.save
      flash[:success] = "Race added!"
      redirect_to races_path
    else
      render :index
    end
  end

  def destroy
    @race.destroy
    flash[:success] = "Race deleted."
    redirect_to races_path
  end

  def index
    respond_to do |format|
      format.html do
        @race = Race.new
      end
      format.json do
        render json: RaceDatatable.new(view_context)
      end
    end
  end

  def update
    @race.update(race_params)
    respond_with_bip(@race)
  end

  private
    def race_params
      params.require(:race).permit(:blizzard_id, :name, :side)
    end
    def set_race
      @race = Race.find(params[:id])
    end
end
