# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
Product.destroy_all
User.destroy_all
Shipping.destroy_all
ProductTemplate.destroy_all

size_chart = ActionDispatch::Http::UploadedFile.new({
     :filename => 'sizechart_hoodie.jpg',
     :type => 'image/jpg',
     :tempfile => File.new("#{Rails.root}/app/assets/images/sizechart-hoodie.jpg")
 })
shipping = Shipping.create(info: "<p>Many of our items are made to order.&nbsp;Please know that there is a <strong>14&nbsp;day&nbsp;crafting period</strong> for each of these.</p></div>
<p>All US orders will be shipped using either Fedex or USPS priority mail. A tracking number will be sent to the email that you provided when placing the order. Normal shipping times for US orders are around 2-3 business days after the item is sent unless you paid for faster delivery.</p>
<p>International shipping cost is calculated by product weight and shipping address. A tracking number will be provided, but once the item is outside of the US, it will not be tracked. Please allow 7-14 business days for international shipping as each country's system for delivering packages is different.</p>
<p>Payment of customs fees or duties is your&nbsp;responsibility, and is due at the time of delivery. For more information on customs or duty fees, please contact your local customs office.</p>")

template1 = ProductTemplate.create(price: 19.99, size: %w(s m l xl), product_type: 'leggins', size_chart: size_chart, shipping: shipping)
template2 = ProductTemplate.create(price: 29.99, size: %w(s m l xl), product_type: 't_shirt', size_chart: size_chart, shipping: shipping)
template3 = ProductTemplate.create(price: 29.99, size: %w(s m l xl), product_type: 'blouse', size_chart: size_chart, shipping: shipping)
template4 = ProductTemplate.create(price: 39.99, size: %w(s m l xl), product_type: 'sweater', size_chart: size_chart, shipping: shipping)

u1 = User.create(name: "user1", email: "t1@gmail.com", password: "password", password_confirmation: "password", artist: true)
u2 = User.create(name: "user2", email: "t2@gmail.com", password: "password", password_confirmation: "password", artist: true)
u3 = User.create(name: "user3", email: "t3@gmail.com", password: "password", password_confirmation: "password", artist: true)
u4 = User.create(name: "user4", email: "t4@gmail.com", password: "password", password_confirmation: "password", artist: true)

description = "<p>the #IceCreamCamo Hoodie.</p>
<p>This 'all over' print crewneck sweatshirt is made using a special sublimation technique to provide a vivid graphic image throughout the shirt.</p>
<p>• 100% Polyester</p>
<p>• All Over Photographic Print</p>
<p>• Made in USA</p>"

25.times do
  Product.create(name: "T-shirt", description:  description, author: u1, product_template: template2)
  Product.create(name: "Sweater", description:  description,  author: u2, product_template: template4)
  Product.create(name: "Blouse", description:  description, author: u3, product_template: template3)
  Product.create(name: "Leggins", description:  description, author: u4, product_template: template1)
end

100.times do |n|
  User.create(name: "user#{n}", email: "t#{n}@gmail.com", password: "password", password_confirmation: "password", artist: false)
end
