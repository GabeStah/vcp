class RacesController < ApplicationController
  respond_to :html, :json
  before_action :require_login
  before_action :admin_user

  def create
    @race = Race.new(race_params)
    if @race.save
      flash[:success] = "Race added!"
      redirect_to races_path
    else
      @races = Race.all.order(:name)
      render 'index'
    end
  end

  def destroy
    Race.find(params[:id]).destroy
    flash[:success] = "Race deleted."
    redirect_to races_path
  end

  def index
    @races = Race.all.order(:name)
    @race = Race.new
  end

  def update
    @race = Race.find(params[:id])
    @race.update_attributes(race_params)
    respond_with_bip(@race)
  end

  private
    def race_params
      params.require(:race).permit(:name)
    end
end
