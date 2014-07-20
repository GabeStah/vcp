class RaidsController < ApplicationController
  before_action :set_raid, only: [:destroy, :edit, :show, :update]

  def create
    # Find characters as marked by id
    characters = params[:characters].collect {|id| Character.find(id)} if params[:characters]
    params = raid_params
    params[:zone] = Zone.find(params[:zone])
    unless params[:ended_at].blank?
      # Parse into DateTime object
      params[:ended_at] = DateTime.strptime(params[:ended_at], DATETIME_FORMAT)
      @default_end = params[:ended_at].strftime(DATETIME_FORMAT)
    end
    unless params[:started_at].blank?
      params[:started_at] = DateTime.strptime(params[:started_at], DATETIME_FORMAT)
      @default_start = params[:started_at].strftime(DATETIME_FORMAT)
    end

    @raid = Raid.new(params)
    if @raid.save
      flash[:success] = "Raid for #{@raid.zone.name} Added!"
      redirect_to raid_path(@raid)
    else
      render :new
    end
  end
  def destroy

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
