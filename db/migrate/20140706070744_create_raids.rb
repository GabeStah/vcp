class CreateRaids < ActiveRecord::Migration
  def change
    create_table :raids do |t|
      t.datetime :started_at
      t.datetime :ended_at, null: true

      t.timestamps
    end
  end
end
