class CharacterClassesController < ApplicationController
  load_and_authorize_resource
  before_action :set_character_class, only: [:destroy, :update]

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
    @character_class.destroy
    flash[:success] = "Class deleted."
    redirect_to classes_path
  end

  def index
    respond_to do |format|
      format.html do
        @character_class = CharacterClass.new
      end
      format.json do
        render json: CharacterClassDatatable.new(view_context)
      end
    end
  end

  def update
    @character_class.update(character_class_params)
    respond_with_bip(@character_class)
  end

  private
    def set_character_class
      @character_class = CharacterClass.find(params[:id])
    end
    def character_class_params
      params.require(:character_class).permit(:blizzard_id, :name)
    end
end
