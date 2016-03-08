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
AdminUser.destroy_all

size_chart = "#{Rails.root}/app/assets/images/sizechart-hoodie.jpg"
product_image = "#{Rails.root}/app/assets/images/t-shirt.png"

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

Config.create(name: 'tax', value: '7.0', input_type: 'short_text')
Config.create(name: 'shipping_info', value: shipping_info, input_type: 'long_text')
Config.create(name: 'shipping_cost', value: '6.0', input_type: 'short_text')
Config.create(name: 'banner_img', config_image: '', input_type: 'image')
Config.create(name: 'banner_url', value: '', input_type: 'short_text')
Config.create(name: 'promo_1_img', config_image: '', input_type: 'image')
Config.create(name: 'promo_1_url', value: '', input_type: 'short_text')
Config.create(name: 'promo_2_img', config_image: '', input_type: 'image')
Config.create(name: 'promo_2_url', value: '', input_type: 'short_text')
Config.create(name: 'promo_3_img', config_image: '', input_type: 'image')
Config.create(name: 'promo_3_url', value: '', input_type: 'short_text')

template1 = ProductTemplate.create(price: 69.95, profit: 25.00, size: %w(s m l xl), product_type: 'hoodie', size_chart: File.new(size_chart))
template2 = ProductTemplate.create(price: 65.00, profit: 25.00, size: %w(s m l xl), product_type: 'sweatshirt', size_chart: File.new(size_chart))
template3 = ProductTemplate.create(price: 39.95, profit: 15.00, size: %w(s m l xl), product_type: 'tee', size_chart: File.new(size_chart))
template4 = ProductTemplate.create(price: 35.00, profit: 15.00, size: %w(s m l xl), product_type: 'tank_top', size_chart: File.new(size_chart))
template5 = ProductTemplate.create(price: 79.95, profit: 30.00, size: %w(s m l xl), product_type: 'yoga_pants', size_chart: File.new(size_chart))

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
  Product.create!(name: Faker::Commerce.product_name, description:  description, author: u1, product_template: template2, image: File.new(product_image))
  Product.create!(name: Faker::Commerce.product_name, description:  description, author: u2, product_template: template4, image: File.new(product_image))
  Product.create!(name: Faker::Commerce.product_name, description:  description, author: u3, product_template: template3, image: File.new(product_image))
  Product.create!(name: Faker::Commerce.product_name, description:  description, author: u4, product_template: template1, image: File.new(product_image))
  Product.create!(name: Faker::Commerce.product_name, description:  description, author: u4, product_template: template5, image: File.new(product_image))
end

100.times do |n|
  User.create(name: "user#{n}", email: "t#{n}@example.com", password: "password", password_confirmation: "password", artist: false)
end

AdminUser.create!(email: 'admin@example.com', password: 'password', password_confirmation: 'password')