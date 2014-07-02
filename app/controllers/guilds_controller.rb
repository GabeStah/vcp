class GuildsController < ApplicationController
  before_action :require_login
  before_action :admin_user

  def create
    @guild = Guild.new(guild_params)
    if @guild.save
      flash[:success] = 'Guild added!'
      redirect_to guild_path(@guild)
    else
      render :new
    end
  end

  def destroy
    Guild.find(params[:id]).destroy
    flash[:success] = 'Guild deleted.'
    redirect_to guilds_url
  end
  def edit
    @guild = Guild.find(params[:id])
  end
  def index
    @guilds = Guild.paginate(page: params[:page]).order(:name)
  end
  def new
    @guild = Guild.new
  end
  def show
    @guild = Guild.find(params[:id])
  end

  def update
    @guild = Guild.find(params[:id])
    if @guild.update_attributes(guild_params)
      if params['battle_net_update']
        flash[:success] = 'Guild updated & Battle.net Update job queued'
        BattleNetWorker.perform_async(id: @guild.id, type: 'guild')
      else
        flash[:success] = 'Guild updated'
      end
      redirect_to @guild
    else
      render :edit
    end
  end

  private
  def guild_params
    params.require(:guild).permit(:achievement_points,
                                  :active,
                                  :battlegroup,
                                  :level,
                                  :name,
                                  :primary,
                                  :region,
                                  :realm,
                                  :side,
                                  :verified)
  end
end
