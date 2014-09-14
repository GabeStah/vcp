class RaidsController < ApplicationController
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
    raid_start_time = DateTime.parse("1/1/2000 #{Settings.raid.start_time}")
    raid_end_time = DateTime.parse("1/1/2000 #{Settings.raid.end_time}")
    @default_start = DateTime.now.change(
        hour: raid_start_time.hour,
        min: raid_start_time.min,
    ).strftime(DATETIME_FORMAT)
    @default_end = DateTime.now.change(
        hour: raid_end_time.hour,
        min: raid_end_time.min,
    ).strftime(DATETIME_FORMAT)
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
      @standings = Standing.includes(:character).order(:points)
    end
end
