class RecreateSettings < ActiveRecord::Migration
  def change
    drop_table :settings
    create_table :settings do |t|
      t.string :raid_start_time
      t.string :raid_end_time

      t.timestamps
    end
  end
end
