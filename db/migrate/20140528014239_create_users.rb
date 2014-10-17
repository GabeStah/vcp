class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :battle_tag

      t.timestamps
    end
  end
end