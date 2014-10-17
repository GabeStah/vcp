class RaidsController < ApplicationController
  load_and_authorize_resource
  before_action :set_raid, only: [:destroy, :edit, :show, :update]
  before_action :set_standings, only: [:create, :new]

  def create
    # Find characters as marked by id
    @raid = Raid.new(raid_params)
    if @raid.save
      @raid.add_participations_from_params(params)
      flash[:success] = "Raid for #{@raid.zone.name} Added!"
      redirect_to raid_path(@raid)
    else
      render :new
    end
  end
  def destroy
    flash[:success] = "Raid #{@raid.full_title} deleted."
    @raid.destroy
    redirect_to :back
  end
  def edit
  end
  def index
    respond_to do |format|
      format.html
      format.json { render json: RaidDatatable.new(view_context) }
    end
  end
  def new
    @raid = Raid.new
    @default_start = TimeManagement.raid_start(format: DATETIME_FORMAT_PICKER)
    @default_end = TimeManagement.raid_end(format: DATETIME_FORMAT_PICKER)
  end
  def show
    @participations = @raid.participations.includes(:character)
  end
  def update
    if @raid.update(raid_params)
      flash[:success] = "#{@raid.full_title} updated."
      redirect_to @raid
    else
      render :edit
    end
  end

  private

  def raid_params
    params.require(:raid).permit(:ended_at,
                                 :started_at,
                                 :zone)
  end

  def set_raid
    @raid = Raid.find(params[:id])
  end

  def set_standings
    @standings = Standing.where(active: true).includes(:character).order(:points)
  end
end
