class SettingsController < ApplicationController
  before_action :set_setting, only: [:update]
  before_action :require_login
  before_action :admin_user

  def index
    @setting = Setting.first
  end

  def update
    if @setting.update(setting_params)
      flash[:success] = "Settings updated & data refreshed."
      redirect_to settings_path
    else
      render :index
    end
  end

  private
    def setting_params
      params.require(:setting).permit(:raid_end_time, :raid_start_time, :tardiness_cutoff_time)
    end
    def set_setting
      @setting = Setting.find(params[:id])
    end
end
