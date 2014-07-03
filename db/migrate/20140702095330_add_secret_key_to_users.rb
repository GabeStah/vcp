class AddSecretKeyToUsers < ActiveRecord::Migration
  def change
    add_column :users, :secret_key, :string
    add_index :users, :secret_key, unique: true
  end
end
