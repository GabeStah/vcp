class CharactersController < ApplicationController
  before_action :require_login, only: [:destroy]
  before_action :admin_user, only: [:destroy]

  def create
    @battle_net = BattleNet.new(character_name: character_params[:name],
                               locale:          character_params[:locale],
                               realm:           character_params[:realm],
                               type:            'character',
                               auto_connect:    true)
    if @battle_net.connected?
      @battle_net.update
      @character = @battle_net.character
      flash[:success] = "Character created!"
      redirect_to @character
    else
      @character = Character.new
      render 'new'
    end
  end

  def destroy
    Character.find(params[:id]).destroy
    flash[:success] = "Character deleted."
    redirect_to characters_url
  end
  def edit

  end
  def index
    @characters = Character.paginate(page: params[:page]).order(:name)
  end
  def new
    @character = Character.new
  end
  def show
    @character = Character.find(params[:id])
  end

  def update
    @character = Character.find(params[:id])
    if @character.update_attributes(user_params)
      flash[:success] = "Character updated"
      redirect_to @character
    else
      render 'edit'
    end
  end

  private
    def character_params
      params.require(:character).permit(:locale,
                                        :name,
                                        :realm)
    end
end
