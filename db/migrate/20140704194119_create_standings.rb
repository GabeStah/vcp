class CreateStandings < ActiveRecord::Migration
  def change
    create_table :standings do |t|
      t.boolean :active, :default => false
      t.decimal :points

      t.timestamps
    end

    add_reference :standings, :character
  end
end
