class AddGainsLossesToStatistics < ActiveRecord::Migration
  def change
    add_column :statistics, :gains_delinquency, :decimal, precision: 10, scale: 6, default: 0
    add_column :statistics, :gains_infraction, :decimal, precision: 10, scale: 6, default: 0
    add_column :statistics, :gains_initial, :decimal, precision: 10, scale: 6, default: 0
    add_column :statistics, :gains_sitting, :decimal, precision: 10, scale: 6, default: 0
    add_column :statistics, :gains_total, :decimal, precision: 10, scale: 6, default: 0

    add_column :statistics, :losses_attendance, :decimal, precision: 10, scale: 6, default: 0
    add_column :statistics, :losses_absence, :decimal, precision: 10, scale: 6, default: 0
    add_column :statistics, :losses_delinquency, :decimal, precision: 10, scale: 6, default: 0
    add_column :statistics, :losses_infraction, :decimal, precision: 10, scale: 6, default: 0
    add_column :statistics, :losses_initial, :decimal, precision: 10, scale: 6, default: 0
    add_column :statistics, :losses_total, :decimal, precision: 10, scale: 6, default: 0
  end
end
