class AddRaidsCountToCharacter < ActiveRecord::Migration
  def change
    add_column :characters, :raids_count, :integer, default: 0, null: false
  end
end
