class RacesController < ApplicationController
  respond_to :html, :json
  before_action :require_login

  def create
    @race = Race.new(race_params)
    if @race.save
      flash[:success] = "Race created!"
      redirect_to @race
    else
      render 'new'
    end
  end

  def destroy
    Race.find(params[:id]).destroy
    flash[:success] = "Race deleted."
    redirect_to races_url
  end

  def edit
  end

  def index
    @races = Race.all.order(:name)
  end

  def new
    @race = Race.new
  end

  def show
    @race = Race.find(params[:id])
  end

  def update
    @race = Race.find(params[:id])
    @race.update_attributes(race_params)
    respond_with @race
  end

  private
    def race_params
      params.require(:race).permit(:name)
    end
end
