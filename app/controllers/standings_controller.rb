class StandingsController < ApplicationController
  before_action :set_standing,                only: [:destroy, :edit, :list_characters, :resume, :retire, :show, :transfer, :update]
  before_action :require_login,               only: [:create, :edit, :destroy, :list_characters, :new, :resume, :retire, :transfer, :update]
  before_action :admin_user,                  only: [:create, :edit, :destroy, :list_characters, :new, :resume, :retire, :transfer, :update]

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

  def list_characters
    respond_to do |format|
      format.html
      format.json do
        render json: StandingTransferDatatable.new(view_context, @standing)
      end
    end
  end

  def resume
    if @standing.resume
      flash[:success] = "Standing for #{@standing.character.full_title} resumed!"
    else
      flash[:error] = "Standing for #{@standing.character.full_title} could not be resumed."
    end
    redirect_to :back
  end

  def retire
    if @standing.retire
      flash[:success] = "Standing for #{@standing.character.full_title} retired!"
    else
      flash[:error] = "Standing for #{@standing.character.full_title} could not be retired."
    end
    redirect_to :back
  end

  def transfer
    if @standing
      character = Character.find(params[:character])
      if character
        if @standing.transfer(character)
          flash[:success] = "Standing transfered to #{@standing.character.full_title}!"
        else
          flash[:error] = "Standing could not be transfered."
        end
        redirect_to :back
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
