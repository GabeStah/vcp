class CharacterClassesController < ApplicationController
  respond_to :html, :json
  before_action :require_login
  before_action :admin_user

  def create
    @character_class = CharacterClass.new(character_class_params)
    if @character_class.save
      flash[:success] = "Class added!"
      redirect_to classes_path
    else
      @character_classes = CharacterClass.all.order(:name)
      render :index
    end
  end

  def destroy
    CharacterClass.find(params[:id]).destroy
    flash[:success] = "Class deleted."
    redirect_to classes_path
  end

  def index
    @character_classes = CharacterClass.all.order(:name)
    @character_class = CharacterClass.new
  end

  def update
    @character_class = CharacterClass.find(params[:id])
    @character_class.update_attributes(character_class_params)
    respond_with_bip(@character_class)
  end

  private
  def character_class_params
    params.require(:character_class).permit(:name)
  end
end
