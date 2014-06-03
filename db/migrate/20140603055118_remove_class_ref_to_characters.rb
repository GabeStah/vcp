class RemoveClassRefToCharacters < ActiveRecord::Migration
  def change
    remove_reference :characters, :class
  end
end
