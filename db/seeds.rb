# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
Product.destroy_all
User.destroy_all

u1 = User.create(name: "user1", email: "t1@gmail.com", password: "password", password_confirmation: "password", artist: true)
u2 = User.create(name: "user2", email: "t2@gmail.com", password: "password", password_confirmation: "password", artist: true)
u3 = User.create(name: "user3", email: "t3@gmail.com", password: "password", password_confirmation: "password", artist: true)
u4 = User.create(name: "user4", email: "t4@gmail.com", password: "password", password_confirmation: "password", artist: true)

25.times do
  Product.create(name: "T-shirt", user: u1, price: 19.99)
  Product.create(name: "Sweater", user: u2, price: 29.99)
  Product.create(name: "Blouse", user: u3, price: 39.99)
  Product.create(name: "Leggins", user: u4, price: 49.99)
end

100.times do |n|
  User.create(name: "user#{n}", email: "t#{n}@gmail.com", password: "password", password_confirmation: "password", artist: true)
end