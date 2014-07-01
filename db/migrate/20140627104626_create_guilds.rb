class CreateGuilds < ActiveRecord::Migration
  def change
    create_table :guilds, options: "DEFAULT CHARSET=utf8 COLLATE=utf8_bin" do |t|
      t.integer :achievement_points
      t.boolean :active
      t.string :battlegroup
      t.boolean :default
      t.integer :level
      t.string :name
      t.string :realm
      t.string :region
      t.integer :side
      t.boolean :verified

      t.timestamps
    end

    add_index :guilds, :name
    add_index :guilds, [:name, :realm]
    add_index :guilds, [:name, :realm, :region], :unique => true
  end
end
