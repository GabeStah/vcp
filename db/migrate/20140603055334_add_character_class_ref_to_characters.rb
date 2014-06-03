class AddCharacterClassRefToCharacters < ActiveRecord::Migration
  def change
    add_reference :characters, :character_class, null: true
  end
end
