class AddExcusedToParticipation < ActiveRecord::Migration
  def change
    add_column :participations, :unexcused, :boolean, default: false
  end
end
