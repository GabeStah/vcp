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
    flash[:success] = "#{@race.name} deleted."
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

  def sync
    authorize! :sync, Race
    BattleNetWorker.perform_async(type: 'race-population')
    flash[:success] = "Sync requested, Races will be updated shortly."
    redirect_to :back
  end

  def update
    @race.update_attributes(race_params)
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
