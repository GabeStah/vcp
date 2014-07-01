class AddSyncedAtToCharacters < ActiveRecord::Migration
  def change
    add_column :characters, :synced_at, :datetime
  end
end
