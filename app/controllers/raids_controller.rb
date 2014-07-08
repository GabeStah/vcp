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
