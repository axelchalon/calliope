# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# Guest players for AI and Guest games storage
masterGuest = Player.create!(
  username: "MasterGuest",
  password: "NUvpàçHvpç!",
  guest: true)
masterAi = Player.create!(
  username: "MasterAi",
  password: "NUvpàçHvpç!",
  ai: true)
