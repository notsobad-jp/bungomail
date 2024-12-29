# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

User.insert({
  id: "1418479c-d5a7-4d29-a174-c5133ca484b6",
  email: "info@notsobad.jp",
  created_at: Time.zone.parse("2018/4/1"),
  updated_at: Time.zone.parse("2018/4/1"),
})