# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
Role.delete_all
role_admin = Role.create!(name: :admin)
role_moderator = Role.create!(name: :moderator)

User.delete_all
# Initial user
user = User.new(email: "gwyattkelsey@gmail.com",
                    password: "hobbes",
                    password_confirmation: "hobbes")
user.roles << role_admin
user.skip_confirmation!
user.save!

# Add test users
99.times do |n|
  name  = Faker::Name.name
  email = Faker::Internet.email
  password  = "password"
  user = User.create!(email: email,
                      password: password,
                      password_confirmation: password)
  user.skip_confirmation!
  user.save!
end

Setting.delete_all
# Create basic settings
Setting.create!(raid_start_time: TimeManagement.raid_start,
                raid_end_time: TimeManagement.raid_start)

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

# Create a new raid
PopulateRaidsWorker.perform_in(5.seconds)

# Populate standings
PopulateStandingsWorker.perform_in(90.seconds)

# Create some participations
#PopulateParticipationsWorker.perform_in(120.seconds)