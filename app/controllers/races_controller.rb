class RacesController < ApplicationController
  before_action :set_race, only: [:destroy, :update]
  before_action :require_login
  before_action :admin_user

  def create
    @race = Race.new(race_params)
    if @race.save
      flash[:success] = "Race added!"
      redirect_to races_path
    else
      @races = Race.all.order(:name)
      render :index
    end
  end

  def destroy
    @race.destroy
    flash[:success] = "Race deleted."
    redirect_to races_path
  end

  def index
    @races = Race.all.order(:name)
    @race = Race.new
  end

  def update
    @race.update_attributes(race_params)
    respond_with_bip(@race)
  end

  private
    def race_params
      params.require(:race).permit(:blizzard_id, :name)
    end
    def set_race
      @race = Race.find(params[:id])
    end
end
