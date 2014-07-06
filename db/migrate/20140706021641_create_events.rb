class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :actor_type
      t.integer :actor_id

      t.timestamps
    end
    add_index :events, :actor_id
  end
end
