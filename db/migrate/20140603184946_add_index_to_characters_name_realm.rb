class AddIndexToCharactersNameRealm < ActiveRecord::Migration
  def change
    add_index :characters, [:name, :realm], :unique => true
  end
end
