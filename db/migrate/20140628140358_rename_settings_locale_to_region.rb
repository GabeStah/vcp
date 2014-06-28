class RenameSettingsLocaleToRegion < ActiveRecord::Migration
  def change
    rename_column :settings, :locale, :region
  end
end
