class CharactersController < ApplicationController
  before_action :require_login, only: [:destroy]
  before_action :is_admin_user, only: [:destroy]

  def create
    battle_net = BattleNet.new(character_name: character_params[:name],
                               locale: character_params[:locale],
                               realm: character_params[:realm],
                               type: 'character')
    if battle_net.invalid?
      flash[:error] = battle_net.errors.empty? ? "Error" : battle_net.errors.full_messages.to_sentence
      redirect_to new_character_path
    else
      json = battle_net.to_json
      unless json.nil?
        @character = Character.update_from_json(json, 'character', character_params[:locale])
        if @character
          flash[:success] = "Character created!"
          redirect_to @character
        else
          render 'new'
        end
      end
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
