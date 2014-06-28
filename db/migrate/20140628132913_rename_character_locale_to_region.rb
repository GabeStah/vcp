class RenameCharacterLocaleToRegion < ActiveRecord::Migration
  def change
    rename_column :characters, :locale, :region
  end
end
