class RaidsController < ApplicationController
  before_action :set_raid, only: [:destroy, :edit, :show, :update]

  def create

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
    @defaultStart = DateTime.now.change(
        hour: raid_start_time ? raid_start_time.hour : DEFAULT_RAID_START_TIME[:hour],
        min: raid_start_time ? raid_start_time.min : DEFAULT_RAID_START_TIME[:min],
    ).strftime('%m/%d/%Y %I:%M %p')
    @defaultEnd   = DateTime.now.change(
        hour: raid_end_time ? raid_end_time.hour : DEFAULT_RAID_END_TIME[:hour],
        min: raid_end_time ? raid_end_time.min : DEFAULT_RAID_END_TIME[:min],
    ).strftime('%m/%d/%Y %I:%M %p')
  end
  def show

  end
  def update

  end

  private
    def set_raid
      @raid = Raid.find(params[:id])
    end
end
