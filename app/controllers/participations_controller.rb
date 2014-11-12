class ParticipationsController < ApplicationController
  load_and_authorize_resource
  before_action :set_participation

  def destroy
    flash[:success] = "Participation for #{@participation.character.full_title} deleted."
    @participation.destroy
    redirect_to @participation.raid
  end

  def duplicate
    new_participation = @participation.dup
    new_participation.timestamp = @participation.timestamp + 1.minute
    if new_participation.save
      flash[:success] = "Participation for #{@participation.character.full_title} duplicated."
    else
      flash[:error] = "Participation for #{@participation.character.full_title} cannot be duplicated."
    end
    redirect_to @participation.raid
  end

  def update
    respond_to do |format|
      if @participation.update_attributes(participation_params)
        format.html {
          flash[:success] = "Participation for #{@participation.character.full_title} updated."
          render @participation.raid
        }
        format.json { respond_with_bip(@participation) }
      else
        format.html { render @participation.raid }
        format.json { respond_with_bip(@participation) }
      end
    end
  end

  private

  def participation_params
    params.require(:participation).permit(:character, :in_raid, :online, :raid, :timestamp, :unexcused)
  end
  def set_participation
    @participation = Participation.find(params[:id])
  end
end
