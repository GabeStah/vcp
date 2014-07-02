class CharactersController < ApplicationController
  before_action :require_login, only: [:destroy]
  before_action :user_owns_character, only: [:claim, :sync]
  before_action :admin_user, only: [:destroy]

  def create
    @character = Character.new(character_params)
    if @character.save
      flash[:success] = 'Character Added!'
      redirect_to character_path(@character)
    else
      render 'new'
    end
  end

  def claim
    @character = Character.find(params[:id])
    if @character.key_match?(params[:key], current_user)
      if @character.update_attributes(user: current_user)
        flash[:success] = 'Character Claimed!'
        redirect_to character_path(@character)
      else
        flash[:error] = 'Key matched but claim failed.'
        render 'show'
      end
    else
      flash[:error] = 'Claim Failed: Provided key does not match.'
      render 'show'
    end
  end

  def destroy
    Character.find(params).destroy
    flash[:success] = "Character deleted."
    redirect_to characters_url
  end
  def edit
    @character = Character.find(params[:id])
  end
  def index
    @characters = Character.paginate(page: params[:page]).order(:name)
  end
  def new
    @character = Character.new
  end
  def show
    @character = Character.find(params[:id])
    # Does user own character?
    if user_owns_character(@character)
      @owned_character = true
    else
      @owned_character = false
    end
    # Add key for basic testing
    @generated_key = Digest::SHA2.hexdigest("#{current_user.secret_key}#{@character.key}") if signed_in? && current_user
  end

  def sync
    @character = Character.find(params[:id])
    if user_owns_character(@character)
      @owned_character = true
      BattleNetWorker.perform_async(id: @character.id,
                                    type: 'character')
      flash[:success] = 'Sync requested, character will be updated shortly.'
    else
      @owned_character = false
      flash[:alert] = 'You cannot sync a character you do not own.'
    end
    redirect_to @character
  end

  def update
    @character = Character.find(params[:id])
    if @character.update_attributes(character_params)
      @character.update_attributes(verified: false)
      BattleNetWorker.perform_async(id: @character.id, type: 'character')
      flash[:success] = "Character updated & Battle.net sync added to queue."
      redirect_to @character
    else
      render 'edit'
    end
  end

  private
    def character_params
      params.require(:character).permit(:name,
                                        :realm,
                                        :region)
    end
    def user_owns_character(character = nil)
      require_login
      return false unless current_user
      return current_user.characters.include?(character || @character)
    end
end
