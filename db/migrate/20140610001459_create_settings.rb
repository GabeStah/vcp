class CreateSettings < ActiveRecord::Migration
  def change
    create_table :settings do |t|
      t.string :guild
      t.string :realm
      t.string :locale

      t.timestamps
    end
  end
end
