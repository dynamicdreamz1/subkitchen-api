# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
Product.destroy_all
User.destroy_all
Config.destroy_all
ProductTemplate.destroy_all

size_chart = "#{Rails.root}/app/assets/images/sizechart-hoodie.jpg"

shipping_info = <<-EOT
<p>
  Many of our items are made to order.&nbsp;
  Please know that there is a <strong>14&nbsp;day&nbsp;crafting period</strong> for each of these.
</p>
<p>
  All US orders will be shipped using either Fedex or USPS priority mail.
  A tracking number will be sent to the email that you provided when placing the order.
  Normal shipping times for US orders are around 2-3 business days after the item is sent unless you paid for faster delivery.
</p>
<p>
  International shipping cost is calculated by product weight and shipping address.
  A tracking number will be provided, but once the item is outside of the US, it will not be tracked.
  Please allow 7-14 business days for international shipping as each country's system for delivering packages is different.
</p>
<p>
  Payment of customs fees or duties is your&nbsp;responsibility, and is due at the time of delivery.
  For more information on customs or duty fees, please contact your local customs office.
</p>
EOT

Config.create(name: 'tax', value: '7.0')
Config.create(name: 'shipping_info', value: shipping_info)
Config.create(name: 'shipping_cost', value: '6.0')

template1 = ProductTemplate.create(price: 19.99, size: %w(s m l xl), product_type: 'leggins', size_chart: File.new(size_chart))
template2 = ProductTemplate.create(price: 29.99, size: %w(s m l xl), product_type: 't_shirt', size_chart: File.new(size_chart))
template3 = ProductTemplate.create(price: 29.99, size: %w(s m l xl), product_type: 'blouse', size_chart: File.new(size_chart))
template4 = ProductTemplate.create(price: 39.99, size: %w(s m l xl), product_type: 'sweater', size_chart: File.new(size_chart))

u1 = User.create(name: "user1", email: "t1@example.com", password: "password", password_confirmation: "password", artist: true)
u2 = User.create(name: "user2", email: "t2@example.com", password: "password", password_confirmation: "password", artist: true)
u3 = User.create(name: "user3", email: "t3@example.com", password: "password", password_confirmation: "password", artist: true)
u4 = User.create(name: "user4", email: "t4@example.com", password: "password", password_confirmation: "password", artist: true)

description = <<-EOT
<p>This 'all over' print crewneck sweatshirt is made using a special sublimation technique to provide a vivid graphic image throughout the shirt.</p>
<p>• 100% Polyester</p>
<p>• All Over Photographic Print</p>
<p>• Made in USA</p>
EOT

25.times do
  Product.create(name: Faker::Commerce.product_name, description:  description, author: u1, product_template: template2)
  Product.create(name: Faker::Commerce.product_name, description:  description, author: u2, product_template: template4)
  Product.create(name: Faker::Commerce.product_name, description:  description, author: u3, product_template: template3)
  Product.create(name: Faker::Commerce.product_name, description:  description, author: u4, product_template: template1)
end

100.times do |n|
  User.create(name: "user#{n}", email: "t#{n}@example.com", password: "password", password_confirmation: "password", artist: false)
end
