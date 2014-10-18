class BattleNetWorker
  include Sidekiq::Worker
  include Errors

  def perform(options={})
    id = options['id']
    type = options['type']
    access_token = options['access_token']
    user_id = options['user_id']
    
    case type
      when 'class-population'
        classes = JSON.parse(Net::HTTP.get_response(URI.parse("https://#{Settings.guild.region}.#{Settings.api.domain}/wow/data/character/classes?apikey=#{ENV['battle_net_api_key']}")).body)
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
        character = Character.find_by(id: id)
        if character
          character.update_from_battle_net
          logger.info "Type: #{type.upcase}, DBID: #{id}, Status: #{character.name} of #{character.realm}-#{character.region.upcase} updated."
        else
          logger.info "Type: #{type.upcase}, DBID: #{id}, Status: Error - #{type.camelize} not found in database."
          raise CharacterError.new(message: "#{type.camelize} not found ID: #{id}")
        end
      when 'characters'
        if access_token
          url = "https://#{Settings.region}.#{Settings.api.domain}/wow/user/characters?access_token=#{access_token}"
          characters = JSON.parse(Net::HTTP.get_response(URI.parse(url)).body)
          user = User.find_by(id: user_id)
          characters['characters'].each do |data|
            character = Character.find_or_create_by(name: data['name'], realm: data['realm'], region: Settings.region)

            character.update_attributes(
              achievement_points: data['achievementPoints'],
              avatar:             character.download_file(character.portrait_url(data['thumbnail'])),
              character_class:    CharacterClass.find_by(blizzard_id: data['class']),
              gender:             data['gender'],
              guild:              data['guild'] ? Guild.find_by(name: data['guild'], realm: data['guildRealm'], region: Settings.region) : nil,
              level:              data['level'],
              portrait:           character.download_file(character.portrait_url(data['thumbnail'], true)),
              race:               Race.find_by(blizzard_id: data['race']),
              synced_at:          Time.zone.now,
              user:               user
            )
          end
          logger.info "BattleNetWorker#characters SUCCESS"
        else
          logger.info "BattleNetWorker#characters FAILURE"
        end
      when 'guild'
        guild = Guild.find_by(id: id)
        # possible:
        # Guild.exists?(id)
        if guild
          guild.update_from_battle_net(type: type)
          logger.info "Type: #{type.upcase}, DBID: #{id}, Status: #{guild.name} of #{guild.realm}-#{guild.region.upcase} updated."
        # else
        #   logger.info "Type: #{type.upcase}, DBID: #{id}, Status: Error - #{type.camelize} not found in database."
        #   raise GuildError.new(message: "#{type.camelize} not found ID: #{id}")
        end
      when 'guild-members'
        guild = Guild.find_by(id: id)
        if guild
          guild.update_from_battle_net(type: type)
          logger.info "Type: #{type.upcase}, DBID: #{id}, Status: #{guild.name} of #{guild.realm}-#{guild.region.upcase} members updated."
        else
          logger.info "Type: #{type.upcase}, DBID: #{id}, Status: Error - #{type.camelize} not found in database."
          raise GuildError.new(message: "#{type.camelize} not found ID: #{id}")
        end
      when 'race-population'
        races = JSON.parse(Net::HTTP.get_response(URI.parse("https://#{Settings.guild.region}.#{Settings.api.domain}/wow/data/character/races?apikey=#{ENV['battle_net_api_key']}")).body)
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