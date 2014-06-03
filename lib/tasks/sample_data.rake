namespace :db do
  desc "Fill database with sample data"
  task populate: :environment do
    User.create!(name: "Gabe Wyatt",
                 email: "gwyattkelsey@gmail.com",
                 password: "hobbes",
                 password_confirmation: "hobbes",
                 admin: true)
    99.times do |n|
      name  = Faker::Name.name
      email = "example-#{n+1}@example.com"
      password  = "password"
      User.create!(name: name,
                   email: email,
                   password: password,
                   password_confirmation: password)
    end

    # Class populate
    classes = ["Death Knight", "Druid", "Hunter", "Mage", "Monk", "Paladin", "Priest", "Rogue", "Shaman", "Warlock", "Warrior"]
    classes.each do |character_class|
      CharacterClass.create!(name: character_class)
    end

    # Race populate
    races = ["Blood Elf", "Draenei", "Dwarf", "Gnome", "Goblin", "Human", "Night Elf", "Orc", "Pandaren", "Tauren", "Troll", "Undead", "Worgen"]
    races.each do |race|
      Race.create!(name: race)
    end
  end
end