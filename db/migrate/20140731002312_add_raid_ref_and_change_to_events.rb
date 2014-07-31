class AddRaidRefAndChangeToEvents < ActiveRecord::Migration
  def change
    add_reference :events, :raid, index: true, null: true
    add_column :events, :change, :decimal, precision: 10, scale: 6
    add_column :events, :type, :string
  end
end
