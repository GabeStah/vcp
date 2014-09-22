class AddAttendanceLossToRaids < ActiveRecord::Migration
  def change
    add_column :raids, :attendance_loss, :decimal, precision: 10, scale: 6
  end
end
