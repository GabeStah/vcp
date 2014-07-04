class AddSlugToGuilds < ActiveRecord::Migration
  def change
      add_column :guilds, :slug, :string
      add_index :guilds, :slug, unique: true
  end
end
