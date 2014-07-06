class CreateParticipations < ActiveRecord::Migration
  def change
    create_table :participations do |t|
      t.belongs_to :character
      t.belongs_to :raid

      t.timestamps
    end
  end
end
