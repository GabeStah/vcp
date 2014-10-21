class CreateZones < ActiveRecord::Migration
  def change
    create_table :zones do |t|
      t.integer :blizzard_id, default: 0
      t.integer :level, null: true
      t.string  :name
      t.string  :zone_type, null: true

      t.timestamps
    end
  end
end
