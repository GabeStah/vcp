class AddIndexToCharactersLocaleNameRealm < ActiveRecord::Migration
  def change
    add_index :characters, [:locale, :name, :realm], :unique => true
  end
end
