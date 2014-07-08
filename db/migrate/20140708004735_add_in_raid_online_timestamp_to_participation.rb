class AddInRaidOnlineTimestampToParticipation < ActiveRecord::Migration
  def change
    add_column :participations, :in_raid, :boolean, default: false
    add_column :participations, :online, :boolean, default: false
    add_column :participations, :timestamp, :datetime
    add_index :participations, [:character_id, :raid_id, :timestamp], unique: true
  end
end
