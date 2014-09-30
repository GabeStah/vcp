class CharactersController < ApplicationController
  before_action :set_character,               only: [:claim, :destroy, :edit, :history, :show, :sync, :unclaim, :update]
  before_action :require_login,               only: [:claim, :create, :edit, :destroy, :new, :sync, :update]
  before_action :require_user_owns_character, only: [:sync]
  before_action :admin_user,                  only: [:destroy]
  before_action :user_owns_character?

  def create
    @character = Character.new(character_params)
    if @character.save
      flash[:success] = "Character #{@character.full_title} Added!"
      redirect_to character_path(@character)
    else
      render :new
    end
  end

  def claim
    if @character.key_match?(params[:key], current_user)
      if @character.update(user: current_user)
        flash[:success] = "Character #{@character.full_title} claimed!"
      else
        flash[:error] = 'Key matched but claim failed.'
      end
    else
      flash[:error] = 'Claim Failed: Provided key does not match.'
    end
    redirect_to :back
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
        render json: CharacterDatatable.new(view_context, type: params[:type])
      end
    end
  end

  def new
    @character = Character.new
  end
  def show
    # Add key for basic testing
    @generated_key = @character.process_key(current_user.secret_key) if signed_in? && current_user

    # Standing
    if @character.standing
      standing = @character.standing
      @data = Hash.new
      @data[:gains] = Hash.new
      @data[:gains][:delinquency] = standing.gains(:delinquency)
      @data[:gains][:infraction] = standing.gains(:infraction)
      @data[:gains][:sitting] = standing.gains(:sitting)
      @data[:gains][:total] = standing.gains(:total)
      @data[:losses] = Hash.new
      @data[:losses][:attendance] = standing.losses(:attendance)
      @data[:losses][:absence] = standing.losses(:absence)
      @data[:losses][:delinquency] = standing.losses(:delinquency)
      @data[:losses][:infraction] = standing.losses(:infraction)
      @data[:losses][:total] = standing.losses(:total)
    end
  end

  def sync
    if @owned_character
      BattleNetWorker.perform_async(id: @character.id,
                                    type: 'character')
      flash[:success] = "Sync requested, #{@character.full_title} will be updated shortly."
    else
      flash[:alert] = 'You cannot sync a character you do not own.'
    end
    redirect_to :back
  end

  def unclaim
    if @character.update(user: nil)
      flash[:success] = "Claim on #{@character.full_title} relinquished!"
    else
      flash[:error] = 'Unclaim failed.'
    end
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
