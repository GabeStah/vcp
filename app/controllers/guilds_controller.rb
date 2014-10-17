class GuildsController < ApplicationController
  load_and_authorize_resource
  before_action :set_guild, only: [:destroy, :edit, :show, :update]

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
    @guild.destroy
    flash[:success] = 'Guild deleted.'
    redirect_to guilds_url
  end
  def edit
  end
  def index
    @guilds = Guild.all.order(:name)
  end
  def new
    @guild = Guild.new
  end
  def show
  end

  def update
    if @guild.update(guild_params)
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
  def set_guild
    @guild = Guild.find(params[:id])
  end
end
