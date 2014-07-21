class RaidsController < ApplicationController
  before_action :set_raid, only: [:destroy, :edit, :show, :update]
  before_action :set_standings, only: [:create, :new]

  def create
    # Find characters as marked by id
    @raid = Raid.new(raid_params)
    if @raid.save
      # Add participation records
      if params[:participation]
        params[:participation].each do |id, status|
          in_raid = false
          online = false
          case status
            when ParticipationStatus::Invited
              in_raid = true
              online = true
            when ParticipationStatus::Online
              in_raid = false
              online = true
            when ParticipationStatus::Excused
              in_raid = false
              online = false
            when ParticipationStatus::Unexcused
              in_raid = false
              online = false
          end
          @raid.participations.create(character: Character.find(id), in_raid: in_raid, online: online, timestamp: @raid.started_at)
        end
      end
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
    def set_standings
      @standings = Standing.all.order(:points)
    end
end
