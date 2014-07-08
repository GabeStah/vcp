class CreateZones < ActiveRecord::Migration
  def change
    create_table :zones do |t|
      t.integer :blizzard_id, null: true
      t.integer :level, null: true
      t.string  :name
      t.string  :zone_type, null: true

      t.timestamps
    end
  end
end
