class AddVisibleToCharacters < ActiveRecord::Migration
  def change
    add_column :characters, :visible, :boolean, default: true
  end
end
