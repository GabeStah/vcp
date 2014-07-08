class AddZoneRefToRaids < ActiveRecord::Migration
  def change
    add_reference :raids, :zones, index: true
  end
end
