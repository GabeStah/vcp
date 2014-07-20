class AddZoneRefToRaids < ActiveRecord::Migration
  def change
    add_reference :raids, :zone, index: true
  end
end
