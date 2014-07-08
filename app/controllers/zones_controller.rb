class ZonesController < ApplicationController
  before_action :set_zone, only: [:edit, :update, :destroy]
  before_action :require_login
  before_action :admin_user

  def index
    @zones = Zone.all.order('level desc', :name)
  end

  def new
    @zone = Zone.new
  end

  def edit
  end

  def create
    @zone = Zone.new(zone_params)
    if @zone.save
      redirect_to zones_path, notice: "#{@zone.name} was successfully created."
    else
      render action: 'new'
    end
  end

  def update
    if @zone.update(zone_params)
      redirect_to zones_path, notice: "#{@zone.name} was successfully updated."
    else
      render action: 'edit'
    end
  end

  def destroy
    @zone.destroy
    redirect_to zones_url
  end

  private
    def set_zone
      @zone = Zone.find(params[:id])
    end

    def zone_params
      params.require(:zone).permit(:blizzard_id, :level, :name, :zone_type)
    end
end
