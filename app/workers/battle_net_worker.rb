class BattleNetWorker
  include Sidekiq::Worker
  include Errors

  def perform(options={})
    id = options['id']
    region = options['region'] || 'us'
    type = options['type']
    
    case type
      when 'class-population'
        classes = JSON.parse(Net::HTTP.get_response(URI.parse("http://#{region}.battle.net/api/wow/data/character/classes")).body)
        if classes['status'] == 'nok'
          raise BattleNetError.new(message: classes['reason'])
        else
          classes['classes'].each do |data|
            character_class = CharacterClass.find_or_create_by!(name: data['name'],
                                                                blizzard_id: data['id'])
          end
          logger.info "Type: #{type.upcase}, Status: Updated Character Classes."
        end
      when 'character'
        character = Character.find(id)
        if character
          character.update_from_battle_net
          logger.info "Type: #{type.upcase}, DBID: #{id}, Status: #{character.name} of #{character.realm}-#{character.region.upcase} updated."
        else
          logger.info "Type: #{type.upcase}, DBID: #{id}, Status: Error - #{type.camelize} not found in database."
          raise CharacterError.new(message: "#{type.camelize} not found ID: #{id}")
        end
      when 'guild'
        guild = Guild.find(id)
        if guild
          guild.update_from_battle_net(type: type)
          logger.info "Type: #{type.upcase}, DBID: #{id}, Status: #{guild.name} of #{guild.realm}-#{guild.region.upcase} updated."
        else
          logger.info "Type: #{type.upcase}, DBID: #{id}, Status: Error - #{type.camelize} not found in database."
          raise GuildError.new(message: "#{type.camelize} not found ID: #{id}")
        end
      when 'guild-members'
        guild = Guild.find(id)
        if guild
          guild.update_from_battle_net(type: type)
          logger.info "Type: #{type.upcase}, DBID: #{id}, Status: #{guild.name} of #{guild.realm}-#{guild.region.upcase} members updated."
        else
          logger.info "Type: #{type.upcase}, DBID: #{id}, Status: Error - #{type.camelize} not found in database."
          raise GuildError.new(message: "#{type.camelize} not found ID: #{id}")
        end
      when 'race-population'
        races = JSON.parse(Net::HTTP.get_response(URI.parse("http://#{region}.battle.net/api/wow/data/character/races")).body)
        if races['status'] == 'nok'
          raise BattleNetError.new(message: races['reason'])
        else
          races['races'].each do |data|
            race = Race.find_or_create_by!(name:        data['name'],
                                           blizzard_id: data['id'],
                                           side:        data['side'])
          end
          logger.info "Type: #{type.upcase}, Status: Updated Races."
        end
    end
  end
end