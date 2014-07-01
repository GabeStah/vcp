class AddIndexToRacesBlizzardIdName < ActiveRecord::Migration
  def change
    add_index :races, [:blizzard_id, :name], :unique => true, name: 'r_b_i'
  end
end
