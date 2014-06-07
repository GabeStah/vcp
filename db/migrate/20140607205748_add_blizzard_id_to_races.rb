class AddBlizzardIdToRaces < ActiveRecord::Migration
  def change
    add_column :races, :blizzard_id, :integer
    add_index :races, :blizzard_id
  end
end
