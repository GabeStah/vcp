class AddIndexToRacesBlizzardIdName < ActiveRecord::Migration
  def change
    add_index :races, [:blizzard_id, :name], :unique => true
  end
end
