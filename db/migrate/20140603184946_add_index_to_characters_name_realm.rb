class AddIndexToCharactersNameRealm < ActiveRecord::Migration
  def change
    add_index :characters, [:name, :realm], :unique => true, name: 'c_n_r'
  end
end
