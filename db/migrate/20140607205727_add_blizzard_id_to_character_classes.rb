class AddBlizzardIdToCharacterClasses < ActiveRecord::Migration
  def change
    add_column :character_classes, :blizzard_id, :integer
    add_index :character_classes, :blizzard_id
  end
end
