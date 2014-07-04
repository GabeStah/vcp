class SyncWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  recurrence do
    daily(1).hour_of_day(2)
  end

  def perform
    Guild.all.each do |guild|
      # Perform basic update
      guild.update_from_battle_net(type: 'guild')
      # Perform member update
      guild.update_from_battle_net(type: 'guild-members')
    end
    # Update all characters not part of a guild
    Character.where(guild: nil) do |character|
      character.update_from_battle_net
    end
  end
end