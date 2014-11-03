Role.delete_all
# Populate from settings
Settings.roles.each do |role, tags|
  Role.create!(name: role.to_s.to_sym)
end

User.delete_all
# Initial user
# user = User.new(battle_tag: "Gabe Wyatt", password: "hobbes", password_confirmation: "hobbes")
# user.roles << role_admin
# #user.skip_confirmation!
# user.save!
#

role_moderator = Role.find_by(name: :moderator)

# Add users
10.times do |n|
  if n >= 5
    name  = Faker::Name.first_name
    password  = "password"
    user = User.create!(battle_tag: "#{name}##{n}",
                        name: name,
                        password: password,
                        password_confirmation: password)
    user.roles << role_moderator
  else

    name  = Faker::Name.first_name
    password  = "password"
    user = User.create!(battle_tag: "#{name}##{n}",
                        name: name,
                        password: password,
                        password_confirmation: password)
  end

  #user.skip_confirmation!
  user.save!
end

CharacterClass.delete_all
# Class populate
BattleNetWorker.perform_async(type: 'class-population')

Race.delete_all
# Race populate
BattleNetWorker.perform_async(type: 'race-population')

Zone.delete_all
# Zones
WOW_ZONE_DEFAULTS.each do |zone|
  Zone.create!(blizzard_id: zone[:blizzard_id],
               level:       zone[:level],
               name:        zone[:name],
               zone_type:   zone[:zone_type])
end

# Delete characters
Character.delete_all

# Delete guilds
Guild.delete_all
#if Rails.env.development?
  Guild.create!(name:   Settings.guild.name,
                realm:  Settings.guild.realm,
                region: Settings.guild.region)
#   Guild.create!(name: 'Method',
#                 realm: 'Twisting Nether',
#                 region: 'eu')
#   Guild.create(name: 'Экзорсус',
#                realm: 'Ревущий фьорд',
#                region: 'eu')
#   Guild.create(name: 'Midwinter',
#                realm: 'Sargeras',
#                region: 'eu')
#end

sleep(5)

[
  'Boggyb',
  'Dougallxin',
  'Airroh',
  'Klik',
  'Tree',
  'Aelloon',
  'Talanvor',
  'Citruss',
  'Nesaru',
  'Takaoni',
  'Nephani',
  'Tayloreds',
  'Kogeth',
  'Kulldar',
  'Blinks',
  'Shaylana',
  'Idtrâpdât',
  'Noblood',
  'Gartzarnn',
  'Deaf',
  'Vikwin',
  'Dyeus',
].each do |character|
  Character.create(created_at: (Time.zone.now - 40.days + rand(0..48).hours - rand(0..240).minutes), name: character, realm: 'Hyjal', region: 'us')
end

# Create a new raid
#PopulateRaidsWorker.perform_in(5.seconds)

# Populate standings
#PopulateStandingsWorker.perform_in(300.seconds)

#DummyDataWorker.perform_in(360.seconds)

# Create some participations
#PopulateParticipationsWorker.perform_in(120.seconds)