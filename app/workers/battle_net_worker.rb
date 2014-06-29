class BattleNetWorker
  include Sidekiq::Worker

  def perform(id, type)
    case type
      when 'guild'
        # guild = Guild.find(id)
        # if guild
        #   guild.update_from_battle_net
        # end
        Guild.find(id).update_from_battle_net
      when 'character'
    end
  end
end