class CharactersController < ApplicationController
  load_and_authorize_resource
  before_action :set_character,               only: [:add_to_standing, :claim, :destroy, :edit, :history, :show, :sync, :unclaim, :update]
  #before_action :require_user_owns_character, only: [:sync]
  before_action :user_owns_character?

  def add_to_standing
    @standing = Standing.new(active: true, character: @character, distribute: params['distribute'] ? true : false, points: params['initial-points'] ? params['initial-points'] : 0)
    if @standing.save
      flash[:success] = 'Standing Added!'
      redirect_to :back
    else
      flash[:error] = 'Standing could not be created!'
      redirect_to :back
    end
  end

  def create
    @character = Character.new(character_params)
    if @character.save
      flash[:success] = "Character #{@character.full_title} Added!"
      redirect_to character_path(@character)
    else
      render :new
    end
  end

  def destroy
    flash[:success] = "Character #{@character.full_title} deleted."
    @character.destroy
    redirect_to :back
  end

  def edit
  end

  def history
    respond_to do |format|
      format.html
      format.json do
        render json: CharacterHistoryDatatable.new(view_context, character: @character, standing: Standing.find_by(character: @character))
      end
    end
  end

  def index
    respond_to do |format|
      format.html
      format.json do
        render json: CharacterDatatable.new(view_context, type: params[:type], user: params[:user] ? User.find(params[:user]) : nil)
      end
    end
  end

  def new
    @character = Character.new
  end

  def show
    # Statistics
    @standing_statistics = @character.standing.standing_statistic if @character.standing
  end

  def sync
    authorize! :sync, @character
    BattleNetWorker.perform_async(id: @character.id,
                                  type: 'character')
    flash[:success] = "Sync requested, #{@character.full_title} will be updated shortly."
    redirect_to :back
  end

  def update
    respond_to do |format|
      if @character.update(character_params)
        format.html {
          @character.update(verified: false)
          BattleNetWorker.perform_async(id: @character.id, type: 'character')
          flash[:success] = "#{@character.full_title} updated & Battle.net sync added to queue."
          redirect_to @character
        }
        format.json { respond_with_bip(@character) }
      else
        format.html { render :edit }
        format.json { respond_with_bip(@character) }
      end
    end
  end

  private
    def character_params
      params.require(:character).permit(:created_at,
                                        :name,
                                        :realm,
                                        :region,
                                        :visible)
    end

    def require_user_owns_character
      @character = Character.find(params[:id])
      unless user_owns_character?
        flash[:alert] = 'You cannot sync a character you do not own.'
        redirect_to @character
      end
    end

    def set_character
      @character = Character.find(params[:id])
    end
end
