class AddRealmToCharacters < ActiveRecord::Migration
  def change
    add_column :characters, :realm, :string
  end
end
