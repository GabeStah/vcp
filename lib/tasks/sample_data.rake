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

    races = ["Tauren", "Pandaren", "Blood Elf", "Night Elf", "Draenei", "Gnome", "Goblin"]
    # Race populate
    races.each do |race|
      Race.create!(name: race)
    end
  end
end