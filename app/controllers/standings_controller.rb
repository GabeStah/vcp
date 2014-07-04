class StandingsController < ApplicationController
  before_action :require_login,               only: [:create, :edit, :destroy, :new, :update]
  before_action :admin_user,                  only: [:create, :edit, :destroy, :new, :update]

  def create
    @standing = Standing.new(character: Character.find(standing_params[:character]))
    if @standing.save
      flash[:success] = 'Standing Added!'
      redirect_to :back
    else
      flash[:error] = 'Standing could not be created!'
      redirect_to :back
    end
  end

  def destroy
    Standing.find(params[:id]).destroy
    flash[:success] = "Standing deleted."
    redirect_to standings_url
  end
  def edit

  end
  def index
    @standings = Standing.all.order(:points)
  end

  def update

  end

  private

  def standing_params
    params.require(:standing).permit(:character)
  end
end