class AddAvatarFingerprintToCharacter < ActiveRecord::Migration
  def change
    add_column :characters, :avatar_fingerprint, :string
  end
end
