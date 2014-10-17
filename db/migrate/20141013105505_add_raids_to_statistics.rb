class AddRaidsToStatistics < ActiveRecord::Migration
  def change
    add_column :statistics, :raids_absent_three_month, :integer
    add_column :statistics, :raids_absent_year, :integer
    add_column :statistics, :raids_absent_total, :integer
    add_column :statistics, :raids_absent_percent, :decimal, precision: 10, scale: 6, default: 0

    add_column :statistics, :raids_attended_three_month, :integer
    add_column :statistics, :raids_attended_year, :integer
    add_column :statistics, :raids_attended_total, :integer
    add_column :statistics, :raids_attended_percent, :decimal, precision: 10, scale: 6, default: 0

    add_column :statistics, :raids_delinquent_three_month, :integer
    add_column :statistics, :raids_delinquent_year, :integer
    add_column :statistics, :raids_delinquent_total, :integer
    add_column :statistics, :raids_delinquent_percent, :decimal, precision: 10, scale: 6, default: 0

    add_column :statistics, :raids_sat_three_month, :integer
    add_column :statistics, :raids_sat_year, :integer
    add_column :statistics, :raids_sat_total, :integer
    add_column :statistics, :raids_sat_percent, :decimal, precision: 10, scale: 6, default: 0
  end
end

