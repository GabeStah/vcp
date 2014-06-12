class CharactersController < ApplicationController
  before_action :require_login, only: [:destroy]
  before_action :is_admin_user, only: [:destroy]

  def destroy
    Character.find(params[:id]).destroy
    flash[:success] = "Character deleted."
    redirect_to characters_url
  end
  def index
    @characters = Character.paginate(page: params[:page]).order(:name)
  end

  private
  def character_params
    params.require(:character).permit(:achievement_points,
                                      :character_class,
                                      :gender,
                                      :guild,
                                      :level,
                                      :locale,
                                      :portrait,
                                      :name,
                                      :race,
                                      :rank,
                                      :realm)
  end
end
