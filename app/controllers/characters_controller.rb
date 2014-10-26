class CharactersController < ApplicationController
  load_and_authorize_resource
  before_action :set_character,               only: [:add_to_standing, :claim, :destroy, :edit, :history, :show, :sync, :unclaim, :update]
  before_action :require_user_owns_character, only: [:sync]
  before_action :user_owns_character?

  def add_to_standing
    @standing = Standing.new(active: true, character: @character)
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
        render json: CharacterDatatable.new(view_context, type: params[:type], user: params[:user])
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
    if @character.update(character_params)
      @character.update(verified: false)
      BattleNetWorker.perform_async(id: @character.id, type: 'character')
      flash[:success] = "#{@character.full_title} updated & Battle.net sync added to queue."
      redirect_to @character
    else
      render :edit
    end
  end

  private
    def character_params
      params.require(:character).permit(:name,
                                        :realm,
                                        :region)
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
