class AddTimeToStatistics < ActiveRecord::Migration
  def change
    add_column :statistics, :time_raiding_three_month, :integer
    add_column :statistics, :time_raiding_year, :integer

    add_column :statistics, :time_absent_three_month, :integer
    add_column :statistics, :time_absent_year, :integer

    add_column :statistics, :time_delinquent_three_month, :integer
    add_column :statistics, :time_delinquent_year, :integer
  end
end
