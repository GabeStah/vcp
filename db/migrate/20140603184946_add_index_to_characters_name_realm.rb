class AddIndexToCharactersNameRealm < ActiveRecord::Migration
  def change
    add_index :characters, [:name, :realm], :unique => true, name: 'char_name_realm'
  end
end
