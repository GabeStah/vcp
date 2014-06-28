class RenameGuildDefaultToPrimary < ActiveRecord::Migration
  def change
    rename_column :guilds, :default, :primary
  end
end
