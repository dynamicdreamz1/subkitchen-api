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
EmailTemplate.destroy_all

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
EmailTemplate.create(name: 'admin_malformed_payment',
                     description: 'Sent automatically to all admins when malformed payment detected.',
                     subject: 'Malformed payment',
                     content: '<b></b>Hi, <br><br>You have <b></b>received malformed payment confirmation request.<br><br>Payment ID: <%= link_to @payment.id, admin_payment_url(@payment) %><br><br><p>Regards,<br>Cloud Team</p>')
EmailTemplate.create(name: 'designer_waiting_products',
                     description: 'Sent automatically/manually to the designer when customer orders product without design.',
                     subject: 'New products are waiting for design',
                     content: '<h3> Hi, </h3><p>New products are waiting for your design<br/><br/><% @products.each do |product| %>Product ID: <%= link_to product.id, admin_product_url(product) %><br/><% end %><br/></p><p>Regards,<br/>Cloud Team</p>')
EmailTemplate.create(name: 'customer_account_password_reset',
                     description: 'Sent automatically to the customer when they ask to reset their password.',
                     subject: 'Set new password',
                     content: "<h3> Hi, </h3><p>Here is your reset password link<br/><br/><a href='<%= @reminder_url %>' target='_blank'><%= @reminder_url %></a><br/><br/></p><p>Regards,<br/>Cloud Team</p>")
EmailTemplate.create(name: 'user_account_email_confirmation',
                     description: 'Sent automatically to the customer when they complete their account registration.	',
                     subject: 'Confirm Your Email',
                     content: "<h3> Hi, </h3><p>Please, confirm your email<br/><br/><a href='<%= @confirmation_url %>' target='_blank'><%= @confirmation_url %></a><br/><br/></p><p>Regards,<br/>Cloud Team</p>")


Config.create(name: 'tax', value: '7.00', input_type: 'short_text')
Config.create(name: 'shipping_info', value: shipping_info, input_type: 'long_text')
Config.create(name: 'shipping_cost', value: '6', input_type: 'short_text')
Config.create(name: 'banner_img', config_image: '', input_type: 'image')
Config.create(name: 'banner_url', value: '', input_type: 'short_text')
Config.create(name: 'promo_1_img', config_image: '', input_type: 'image')
Config.create(name: 'promo_1_url', value: '', input_type: 'short_text')
Config.create(name: 'promo_2_img', config_image: '', input_type: 'image')
Config.create(name: 'promo_2_url', value: '', input_type: 'short_text')
Config.create(name: 'promo_3_img', config_image: '', input_type: 'image')
Config.create(name: 'promo_3_url', value: '', input_type: 'short_text')
Config.create(name: 'designers', value: 'designer@example.com', input_type: 'short_text')

template1 = ProductTemplate.create(price: 69.95, profit: 25.00, size: %w(s m l xl), product_type: 'hoodie', size_chart: File.new(size_chart))
template2 = ProductTemplate.create(price: 65.00, profit: 25.00, size: %w(s m l xl), product_type: 'sweatshirt', size_chart: File.new(size_chart))
template3 = ProductTemplate.create(price: 39.95, profit: 15.00, size: %w(s m l xl), product_type: 'tee', size_chart: File.new(size_chart))
template4 = ProductTemplate.create(price: 35.00, profit: 15.00, size: %w(s m l xl), product_type: 'tank_top', size_chart: File.new(size_chart))
template5 = ProductTemplate.create(price: 79.95, profit: 30.00, size: %w(s m l xl), product_type: 'yoga_pants', size_chart: File.new(size_chart))

u1 = User.create!(name: "user1", handle: "user1", email: "t1@example.com", password: "password", password_confirmation: "password", email_confirmed: true, artist: true)
u2 = User.create!(name: "user2", handle: "user2", email: "t2@example.com", password: "password", password_confirmation: "password", email_confirmed: true, artist: true)
u3 = User.create!(name: "user3", handle: "user3", email: "t3@example.com", password: "password", password_confirmation: "password", email_confirmed: true, artist: true)
u4 = User.create!(name: "user4", handle: "user4", email: "t4@example.com", password: "password", password_confirmation: "password", email_confirmed: true, artist: true)

description = <<-EOT
<p>This 'all over' print crewneck sweatshirt is made using a special sublimation technique to provide a vivid graphic image throughout the shirt.</p>
<p>• 100% Polyester</p>
<p>• All Over Photographic Print</p>
<p>• Made in USA</p>
EOT

25.times do
  p = Product.create!(name: Faker::Commerce.product_name, description: description, author: u1, product_template: template2, image: File.new(product_image))
  Product.create!(name: Faker::Commerce.product_name, description: description, author: u2, product_template: template4, image: File.new(product_image))
  Product.create!(name: Faker::Commerce.product_name, description: description, author: u3, product_template: template3, image: File.new(product_image))
  Product.create!(name: Faker::Commerce.product_name, description: description, author: u4, product_template: template1, image: File.new(product_image))
  Product.create!(name: Faker::Commerce.product_name, description: description, author: u4, product_template: template5, image: File.new(product_image))
  p.likes.create!(user: u2)
  p.likes.create!(user: u3)
  p.likes.create!(user: u4)
end

100.times do |n|
  User.create(name: "user#{n}", email: "t#{n}@example.com", password: "password", password_confirmation: "password", artist: false)
end

Product.all.each do |p|
  30.times do
    offset = rand(User.count)
    p.comments.create(content: Faker::Lorem.paragraph, user: User.offset(offset).first)
  end
end

AdminUser.create!(email: 'admin@example.com', password: 'password', password_confirmation: 'password')
