class RaidsController < ApplicationController
  before_action :set_raid, only: [:destroy, :edit, :show, :update]

  def create
    # Find characters as marked by id
    characters = params[:characters].collect {|id| Character.find(id)} if params[:characters]
    @raid = Raid.new(raid_params)
    if @raid.save
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
    @raids = Raid.paginate(page: params[:page]).order(:started_at)
  end
  def new
    @raid = Raid.new
    setting = Setting.first
    unless setting.nil?
      raid_start_time = DateTime.parse("1/1/2000 #{setting.raid_start_time}")
      raid_end_time = DateTime.parse("1/1/2000 #{setting.raid_end_time}")
    end
    @default_start = DateTime.now.change(
        hour: raid_start_time ? raid_start_time.hour : DEFAULT_RAID_START_TIME[:hour],
        min: raid_start_time ? raid_start_time.min : DEFAULT_RAID_START_TIME[:min],
    ).strftime(DATETIME_FORMAT)
    @default_end = DateTime.now.change(
        hour: raid_end_time ? raid_end_time.hour : DEFAULT_RAID_END_TIME[:hour],
        min: raid_end_time ? raid_end_time.min : DEFAULT_RAID_END_TIME[:min],
    ).strftime(DATETIME_FORMAT)
    @standings = Standing.all.order(:points)
  end
  def show
  end
  def update
    if @raid.update_attributes(raid_params)
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
end
