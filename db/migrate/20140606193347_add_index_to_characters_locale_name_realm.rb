class AddIndexToCharactersLocaleNameRealm < ActiveRecord::Migration
  def change
    add_index :characters, [:locale, :name, :realm], :unique => true, name: 'char_name_realm_loc'
  end
end
