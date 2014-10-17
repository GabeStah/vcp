class CreateStatistics < ActiveRecord::Migration
  def change
    create_table :statistics do |t|
      t.string :record_type
      t.integer :record_id

      t.timestamps
    end

    add_index :statistics, [:record_type, :record_id], unique: true
  end
end
