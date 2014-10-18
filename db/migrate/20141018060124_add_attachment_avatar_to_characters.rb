class AddAttachmentAvatarToCharacters < ActiveRecord::Migration
  def self.up
    change_table :characters do |t|
      t.attachment :avatar
    end
  end

  def self.down
    remove_attachment :characters, :avatar
  end
end
