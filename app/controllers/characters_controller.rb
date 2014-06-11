class CharactersController < ApplicationController
  def destroy
    Character.find(params[:id]).destroy
    flash[:success] = "Character deleted."
    redirect_to characters_url
  end
  def index
    @characters = Character.paginate(page: params[:page]).order(:name)
  end
end
