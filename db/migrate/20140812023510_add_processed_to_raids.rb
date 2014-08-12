class AddProcessedToRaids < ActiveRecord::Migration
  def change
    add_column :raids, :processed, :boolean, default: false
  end
end
