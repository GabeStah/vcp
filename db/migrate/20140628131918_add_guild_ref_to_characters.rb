class AddGuildRefToCharacters < ActiveRecord::Migration
  def change
    # Drop existing guild column
    remove_column :characters, :guild

    # Add new guild_id column
    add_reference :characters, :guild, index: true, null: true
  end
end
