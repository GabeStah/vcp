class AddSeededToStandings < ActiveRecord::Migration
  def change
    add_column :standings, :seeded, :boolean, default: true
  end
end
