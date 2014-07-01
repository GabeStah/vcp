class AddVerifiedToCharacters < ActiveRecord::Migration
  def change
    add_column :characters, :verified, :boolean, :default => false
    add_index :characters, :verified
  end
end
