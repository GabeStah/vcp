class SettingsController < ApplicationController
  before_action :require_login
  before_action :is_admin_user

  def index
    @setting = Setting.find(1)
  end

  def update
    @setting = Setting.find(params[:id])
    if @setting.update_attributes(setting_params)
      flash[:success] = "Settings updated."
      redirect_to settings_path
    else
      render 'index'
    end
  end

  private
    def setting_params
      params.require(:setting).permit(:guild, :realm, :locale)
    end
end
