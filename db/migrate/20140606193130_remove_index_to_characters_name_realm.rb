class RemoveIndexToCharactersNameRealm < ActiveRecord::Migration
  def up
    remove_index :characters, [:name, :realm]
  end
  def down
    add_index :characters, [:name, :realm], :unique => true, name: 'char_name_realm'
  end
end
