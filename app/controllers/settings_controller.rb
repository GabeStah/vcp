class SettingsController < ApplicationController
  respond_to :html, :json
  before_action :require_login, only: :settings
  before_action :is_admin_user, only: :settings

  def create
  end

  def destroy
  end

  def index
    @guild = Setting.find_by(name: "guild")
  end

  def update
    @setting = Setting.find(params[:id])
    @setting.update_attributes(setting_params)
    respond_with_bip(@setting)
  end

  private
    def setting_params
      params.require(:setting).permit(:data_type, :name, :value)
    end
end