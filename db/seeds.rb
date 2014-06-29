# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
User.delete_all
# Initial user
User.create!(name: "Gabe Wyatt",
             email: "gwyattkelsey@gmail.com",
             password: "hobbes",
             password_confirmation: "hobbes",
             admin: true)