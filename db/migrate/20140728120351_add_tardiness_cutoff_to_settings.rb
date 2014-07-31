class AddTardinessCutoffToSettings < ActiveRecord::Migration
  def change
    add_column :settings, :tardiness_cutoff_time, :integer, default: 60
  end
end
