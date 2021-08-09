# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

User.insert({
  id: "37f4e418-227e-485d-ab41-c50f887b9956",
  email: "info@notsobad.jp",
  created_at: Time.zone.parse("2018/4/1"),
  updated_at: Time.zone.parse("2018/4/1"),
})

Channel.insert_all([
  {
    code: "bungomail-official",
    id: "1418479c-d5a7-4d29-a174-c5133ca484b6",
    user_id: "37f4e418-227e-485d-ab41-c50f887b9956",
    updated_at: "2018-05-01 00:00:00",
    created_at: "2018-05-01 00:00:00",
  },
  {
    code: "long-novel",
    id: "470a73fb-d1ae-4ffb-9c6b-5b9dc292f4ef",
    user_id: "37f4e418-227e-485d-ab41-c50f887b9956",
    updated_at: "2021-05-01 00:00:00",
    created_at: "2021-05-01 00:00:00"
  }
])

ChannelProfile.insert_all([
  {
    id: "1418479c-d5a7-4d29-a174-c5133ca484b6",
    title: "ブンゴウメール公式チャネル",
    updated_at: "2018-05-01 00:00:00",
    created_at: "2018-05-01 00:00:00",
  },
  {
    id: "470a73fb-d1ae-4ffb-9c6b-5b9dc292f4ef",
    title: "長編作品チャネル",
    updated_at: "2021-05-01 00:00:00",
    created_at: "2021-05-01 00:00:00"
  }
])
