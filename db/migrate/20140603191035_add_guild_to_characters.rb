class AddGuildToCharacters < ActiveRecord::Migration
  def change
    add_column :characters, :guild, :string, null: true
  end
end
