class AddCharacterCountersToUser < ActiveRecord::Migration
  def change
    add_column :users, :characters_count, :integer, default: 0, null: false
    add_column :users, :characters_verified_count, :integer, default: 0, null: false
  end
end
