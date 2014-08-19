class StandingsController < ApplicationController
  before_action :set_standing,                only: [:destroy, :edit, :show, :update]
  before_action :require_login,               only: [:create, :edit, :destroy, :new, :update]
  before_action :admin_user,                  only: [:create, :edit, :destroy, :new, :update]

  def create
    @standing = Standing.new(active: true, character: Character.find(standing_params[:character]))
    if @standing.save
      flash[:success] = 'Standing Added!'
      redirect_to :back
    else
      flash[:error] = 'Standing could not be created!'
      redirect_to :back
    end
  end

  def destroy
    @standing.destroy
    flash[:success] = "Standing deleted."
    redirect_to standings_url
  end
  def edit

  end
  def index
    #@standings = Standing.includes(character: [:character_class, :guild]).where(active: true).order(:points)
    respond_to do |format|
      format.html
      format.json do
        render json: StandingDatatable.new(view_context, type: params[:type])
      end
    end
  end

  def update

  end

  private

    def standing_params
      params.require(:standing).permit(:character)
    end
    def set_standing
      @standing = Standing.find(params[:id])
    end
end
