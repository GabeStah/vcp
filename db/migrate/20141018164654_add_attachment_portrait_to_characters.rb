class AddAttachmentPortraitToCharacters < ActiveRecord::Migration
  def self.up
    change_table :characters do |t|
      t.attachment :portrait
    end
  end

  def self.down
    remove_attachment :characters, :portrait
  end
end
