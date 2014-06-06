class AddLocaleToCharacters < ActiveRecord::Migration
  def change
    add_column :characters, :locale, :string
  end
end
