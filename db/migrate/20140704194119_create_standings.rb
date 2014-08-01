class CreateStandings < ActiveRecord::Migration
  def change
    create_table :standings do |t|
      t.boolean :active, default: false
      t.decimal :points, precision: 10, scale: 6, default: 0

      t.timestamps
    end

    add_reference :standings, :character
  end
end
