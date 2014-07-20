class CreateRaids < ActiveRecord::Migration
  def change
    create_table :raids do |t|
      t.datetime :started_at, index: true, unique: true
      t.datetime :ended_at, null: true, index: true, unique: true

      t.timestamps
    end
  end
end
