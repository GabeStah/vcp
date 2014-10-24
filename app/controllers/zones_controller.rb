class ZonesController < ApplicationController
  load_and_authorize_resource
  before_action :set_zone, only: [:destroy, :update]

  def create
    @zone = Zone.new(zone_params)
    if @zone.save
      redirect_to zones_path, notice: "#{@zone.name} was successfully created."
    else
      render :index
    end
  end

  def destroy
    @zone.destroy
    flash[:success] = "Zone deleted."
    redirect_to zones_path
  end

  def index
    respond_to do |format|
      format.html do
        @zone = Zone.new
      end
      format.json do
        render json: ZoneDatatable.new(view_context)
      end
    end
  end

  def update
    @zone.update_attributes(zone_params)
    respond_with_bip(@zone)
  end

  private
    def set_zone
      @zone = Zone.find(params[:id])
    end

    def zone_params
      params.require(:zone).permit(:blizzard_id, :level, :name, :zone_type)
    end
end
