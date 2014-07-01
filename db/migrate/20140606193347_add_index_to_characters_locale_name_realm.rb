class AddIndexToCharactersLocaleNameRealm < ActiveRecord::Migration
  def change
    add_index :characters, [:locale, :name, :realm], :unique => true, name: 'c_l_n_r'
  end
end
