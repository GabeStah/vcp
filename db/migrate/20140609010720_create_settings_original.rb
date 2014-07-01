class CreateSettingsOriginal < ActiveRecord::Migrationclass AddIndexToRacesBlizzardIdName < ActiveRecord::Migration

  def change
    create_table :settings do |t|
      t.string :name
      t.string :value
      t.string :data_type

      t.timestamps
    end

    add_index :settings, :name
    add_index :settings, :value
  end
end
