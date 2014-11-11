class AddShowHiddenCharactersToUser < ActiveRecord::Migration
  def change
    add_column :users, :show_hidden_characters, :boolean, default: false
  end
end
