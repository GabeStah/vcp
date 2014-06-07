class AddSideToRaces < ActiveRecord::Migration
  def change
    add_column :races, :side, :string
  end
end
