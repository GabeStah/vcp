class AddPortraitFingerprintToCharacter < ActiveRecord::Migration
  def change
    add_column :characters, :portrait_fingerprint, :string
  end
end
