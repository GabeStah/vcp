class SettingsController < ApplicationController
  before_action :require_login
  before_action :admin_user

  def index
    @setting = Setting.first
  end

  def update
    @setting = Setting.find(params[:id])
    # Repopulate character data
    @battle_net = BattleNet.new(guild:        setting_params[:guild],
                                realm:        setting_params[:realm],
                                region:       setting_params[:region],
                                type:         "guild",
                                auto_connect: true)
    if @battle_net.connected?
      @battle_net.update
      if @setting.update_attributes(setting_params)
        flash[:success] = "Settings updated & data refreshed."
        redirect_to settings_path
      else
        render :index
      end
    else
      render :index
    end
  end

  private
    def setting_params
      params.require(:setting).permit(:guild, :realm, :region)
    end
end
