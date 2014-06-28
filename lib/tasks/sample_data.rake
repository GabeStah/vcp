namespace :app do

  # Checks and ensures task is not run in production.
  task :ensure_development_environment => :environment do
    if Rails.env.production?
      raise "\nI'm sorry, I can't do that.\n(You're asking me to drop your production database.)"
    end
  end

  # Custom install for developement environment
  desc "Install"
  task :install => [:ensure_development_environment, "db:migrate", "db:test:prepare", "db:seed", "app:populate", "spec"]

  # Custom reset for developement environment
  desc "Reset"
  task :reset => [:ensure_development_environment, "db:drop", "db:create", "db:migrate", "db:test:prepare", "db:seed", "app:populate"]

  # Populates development data
  desc "Populate the database with development data."
  task :populate => :environment do
    # Removes content before populating with data to avoid duplication
    Rake::Task['db:reset'].invoke

    # INSERT BELOW

    User.create!(name: "Gabe Wyatt",
                 email: "gwyattkelsey@gmail.com",
                 password: "hobbes",
                 password_confirmation: "hobbes",
                 admin: true)
    99.times do |n|
      name  = Faker::Name.name
      email = Faker::Internet.email
      password  = "password"
      User.create!(name: name,
                   email: email,
                   password: password,
                   password_confirmation: password)
    end

    # Admin settings
    settings = Setting.find_or_create_by(region: "US",
                                         guild: "Vox Immortalis",
                                         realm: "Hyjal")

    # Class populate
    classes = JSON.parse(Net::HTTP.get_response(URI.parse("http://#{settings.region.downcase}.battle.net/api/wow/data/character/classes")).body)
    classes['classes'].each do |character_class|
      CharacterClass.create!(name: character_class['name'],
                             blizzard_id: character_class['id'])
    end

    # Race populate
    races = JSON.parse(Net::HTTP.get_response(URI.parse("http://#{settings.region.downcase}.battle.net/api/wow/data/character/races")).body)
    races['races'].each do |race|
      Race.create!(name:        race['name'],
                   blizzard_id: race['id'],
                   side:        race['side'])
    end

    # Generate initial Characters from API
    battle_net = BattleNet.new(guild:        settings.guild,
                               realm:        settings.realm,
                               region:       settings.region,
                               type:         "guild",
                               auto_connect: true)

    battle_net.update if battle_net.connected?

    # INSERT ABOVE
  end

end