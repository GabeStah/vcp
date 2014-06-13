class SettingsController < ApplicationController
  before_action :require_login
  before_action :is_admin_user

  def index
    @setting = Setting.find(1)
  end

  def update
    # Repopulate character data
    battle_net = BattleNet.new(guild:   setting_params[:guild],
                               realm:   setting_params[:realm],
                               locale:  setting_params[:locale],
                               type:    "guild")
    battle_net.populate_database
    if battle_net.errors.empty?
      @setting = Setting.find(params[:id])
      if @setting.update_attributes(setting_params)
        flash[:success] = "Settings updated & data refreshed."
        redirect_to settings_path
      else
        render 'index'
      end
    else
      redirect_to settings_path
    end
  end

  private
    def setting_params
      params.require(:setting).permit(:guild, :realm, :locale)
    end
end
