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
Order.destroy_all
TemplateVariant.destroy_all
Color.destroy_all
Payment.destroy_all

size_chart = "#{Rails.root}/app/assets/images/sizechart-hoodie.jpg"
product_image = "#{Rails.root}/app/assets/images/t-shirt.png"

def template_image(img_name, ext = 'jpg')
  "#{Rails.root}/app/assets/images/templates/#{img_name}.#{ext}"
end

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
EmailTemplate.create!(name: 'MalformedPaymentNotifier',
                      description: 'Sent automatically to all admins when malformed payment detected.',
                      subject: 'Malformed payment',
                      content: '<h3>Hi,</h3>You have <b></b>received malformed payment confirmation request.<br><br>Payment ID: <a target="_blank" title="Link: PAYMENT_ID" href="PAYMENT_URL">PAYMENT_ID</a><br><br><p>Regards,<br>Cloud Team</p>')
EmailTemplate.create!(name: 'WaitingProductsNotifier',
                      description: 'Sent automatically/manually to the designer when customer orders product without design.',
                      subject: 'New products are waiting for design',
                      content: '<h3> Hi, </h3><p>New products are waiting for your design<br><br></p><p>PRODUCTS_LIST</p><p>Regards,</p><p>Cloud Team</p>')
EmailTemplate.create!(name: 'AccountResetPassword',
                      description: 'Sent automatically to the customer when they ask to reset their password.',
                      subject: 'Set new password',
                      content: '<h3> Hi, </h3><p>Here is your reset password link:<br><br><a target="_blank" href="REMINDER_URL">REMINDER_URL</a><br><br></p><p>Regards,<br>Cloud Team</p>')
EmailTemplate.create!(name: 'AccountEmailConfirmation',
                      description: 'Sent automatically to the customer when they complete their account registration.	',
                      subject: 'Confirm Your Email',
                      content: '<h3> Hi, </h3><p>Please, confirm your email<br><br><a target="_blank" title="Link: CONFIRMATION_URL" href="CONFIRMATION_URL">CONFIRMATION_URL</a><br><br></p><p>Regards,<br>Cloud Team</p>')
puts 'EmailTemplate created'
Config.create!(name: 'themes', value: '3D, Abstract, Animal, Galaxy, Digital, Comic', input_type: 'short_text')
Config.create!(name: 'tax', value: '7.00', input_type: 'short_text')
Config.create!(name: 'shipping_info', value: shipping_info, input_type: 'long_text')
Config.create!(name: 'shipping_cost', value: '6', input_type: 'short_text')
Config.create!(name: 'banner_img', config_image: File.new(Rails.root.join('db/seeds/images/banner.png')), input_type: 'image')
Config.create!(name: 'banner_url', value: 'http://localhost:4200/create', input_type: 'short_text')
Config.create!(name: 'promo_1_img', config_image: File.new(Rails.root.join('db/seeds/images/promo1.png')), input_type: 'image')
Config.create!(name: 'promo_1_url', value: 'http://localhost:4200/products', input_type: 'short_text')
Config.create!(name: 'promo_2_img', config_image: File.new(Rails.root.join('db/seeds/images/promo2.png')), input_type: 'image')
Config.create!(name: 'promo_2_url', value: 'http://localhost:4200/products', input_type: 'short_text')
Config.create!(name: 'promo_3_img', config_image: File.new(Rails.root.join('db/seeds/images/promo3.png')), input_type: 'image')
Config.create!(name: 'promo_3_url', value: 'http://localhost:4200/products', input_type: 'short_text')
Config.create!(name: 'designers', value: 'designer@example.com', input_type: 'short_text')

Config.create!(name: 'invoice_line_1', value: 'SubKitchen', input_type: 'short_text')
Config.create!(name: 'invoice_line_2', value: 'SubKitchen', input_type: 'short_text')
Config.create!(name: 'invoice_line_3', value: 'SubKitchen', input_type: 'short_text')
Config.create!(name: 'invoice_line_4', value: 'SubKitchen', input_type: 'short_text')
Config.create!(name: 'invoice_line_5', value: 'SubKitchen', input_type: 'short_text')
Config.create!(name: 'invoice_line_6', value: 'SubKitchen', input_type: 'short_text')
puts 'Config created'

black = Color.create!(name: 'Black', color_value: '#000000')
white = Color.create!(name: 'White', color_value: '#ffffff')

puts 'Color created'

sizes = %w(SM MD LG XL 2X 3X)

template1 = ProductTemplate.create!(price: 69.95,
                                    profit: 25.00,
                                    size: sizes,
                                    template_image: File.new(template_image('hoodie')),
                                    template_mask: File.new(template_image('hoodie-mask', 'png')),
                                    product_type: 'hoodie',
                                    description: 'Super dumper custom design',
                                    size_chart: File.new(size_chart))
template2 = ProductTemplate.create!(price: 65.00,
                                    profit: 25.00,
                                    size: sizes,
                                    template_image: File.new(template_image('sweatshirt')),
                                    template_mask: File.new(template_image('sweatshirt-mask', 'png')),
                                    product_type: 'sweatshirt',
                                    description: 'Super dumper custom design',
                                    size_chart: File.new(size_chart))
template3 = ProductTemplate.create!(price: 39.95,
                                    profit: 15.00,
                                    size: sizes,
                                    template_image: File.new(template_image('shirt')),
                                    template_mask: File.new(template_image('shirt-mask', 'png')),
                                    product_type: 'tee',
                                    description: 'Super dumper custom design',
                                    size_chart: File.new(size_chart))
template4 = ProductTemplate.create!(price: 35.00,
                                    profit: 15.00,
                                    size: sizes,
                                    template_image: File.new(template_image('tank')),
                                    template_mask: File.new(template_image('tank-mask', 'png')),
                                    product_type: 'tank_top',
                                    description: 'Super dumper custom design',
                                    size_chart: File.new(size_chart))
template5 = ProductTemplate.create!(price: 79.95,
                                    profit: 30.00,
                                    size: sizes,
                                    template_image: File.new(template_image('yoga_pants')),
                                    template_mask: File.new(template_image('yoga_pants-mask', 'png')),
                                    product_type: 'yoga_pants',
                                    description: 'Super dumper custom design',
                                    size_chart: File.new(size_chart))

puts 'ProductTemplate created'

t1 = TemplateVariant.create!(name: 'all over', color: white, product_template: template1)
t2 = TemplateVariant.create!(name: 'all over', color: white, product_template: template2)
TemplateVariant.create!(name: 'all over', color: white, product_template: template3)
TemplateVariant.create!(name: 'all over', color: white, product_template: template4)
TemplateVariant.create!(name: 'all over', color: white, product_template: template5)

TemplateVariant.create!(name: 'center', color: black, product_template: template1)
TemplateVariant.create!(name: 'center', color: black, product_template: template2)
TemplateVariant.create!(name: 'center', color: black, product_template: template3)
TemplateVariant.create!(name: 'center', color: black, product_template: template4)

puts 'TemplateVariant created'

u1 = User.create!(name: 'user1', handle: 'user1', email: 't1@example.com', password: 'password', password_confirmation: 'password', email_confirmed: true, artist: true, status: :verified)
u2 = User.create!(name: 'user2', handle: 'user2', email: 't2@example.com', password: 'password', password_confirmation: 'password', email_confirmed: true, artist: true, status: :verified)
u3 = User.create!(name: 'user3', handle: 'user3', email: 't3@example.com', password: 'password', password_confirmation: 'password', email_confirmed: true, artist: true, status: :verified)
u4 = User.create!(name: 'user4', handle: 'user4', email: 't4@example.com', password: 'password', password_confirmation: 'password', email_confirmed: true, artist: true, status: :verified)

description = <<-EOT
<p>This 'all over' print crewneck sweatshirt is made using a special sublimation technique to provide a vivid graphic image throughout the shirt.</p>
<p>• 100% Polyester</p>
<p>• All Over Photographic Print</p>
<p>• Made in USA</p>
EOT

5.times do
  p = Product.create!(name: Faker::Commerce.product_name,
                      description: description,
                      author: u1,
                      product_template: template2,
                      uploaded_image: File.new(product_image),
                      image: File.new(product_image),
                      preview: File.new(product_image),
                      published: true,
                      description: "Super dumper custom design",
                      published_at: Date.today)
  Product.create!(name: Faker::Commerce.product_name,
                  description: description,
                  author: u2,
                  product_template: template4,
                  uploaded_image: File.new(product_image),
                  image: File.new(product_image),
                  preview: File.new(product_image),
                  published: true,
                  description: "Super dumper custom design",
                  published_at: Date.today)
  Product.create!(name: Faker::Commerce.product_name,
                  description: description,
                  author: u3,
                  product_template: template3,
                  uploaded_image: File.new(product_image),
                  image: File.new(product_image),
                  preview: File.new(product_image),
                  published: true,
                  description: "Super dumper custom design",
                  published_at: Date.today)
  Product.create!(name: Faker::Commerce.product_name,
                  description: description,
                  author: u4,
                  product_template: template1,
                  uploaded_image: File.new(product_image),
                  image: File.new(product_image),
                  preview: File.new(product_image),
                  published: true,
                  description: "Super dumper custom design",
                  published_at: Date.today)
  Product.create!(name: Faker::Commerce.product_name,
                  description: description,
                  author: u4,
                  product_template: template5,
                  uploaded_image: File.new(product_image),
                  image: File.new(product_image),
                  preview: File.new(product_image),
                  published: true,
                  description: "Super dumper custom design",
                  published_at: Date.today)
  p.likes.create!(user: u2)
  p.likes.create!(user: u3)
  p.likes.create!(user: u4)
end

puts 'Product created'

100.times do |n|
  User.create(name: "user#{n}", email: "t#{n}@example.com", password: 'password', password_confirmation: 'password', artist: false)
end

puts 'User created'

Product.all.each do |p|
  30.times do
    offset = rand(User.count)
    p.comments.create(content: Faker::Lorem.paragraph, user: User.offset(offset).first)
  end
end

puts 'Comment created'

AdminUser.create!(email: 'admin@example.com', password: 'password', password_confirmation: 'password')

puts 'AdminUser created'

product = Product.first
order = Order.create!(purchased_at: DateTime.now, purchased: true, email: 'johndoe@example.com', order_status: 'cooking', full_name: 'John Doe', address: '123 Main St', city: 'Anytown', region: 'CA', zip: '12345-6789', country: 'USA')
OrderItem.create!(order: order, product: product, quantity: 2, size: 's', profit: product.product_template.profit * 2, template_variant: t1)
OrderItem.create!(order: order, product: product, quantity: 3, size: 'm', profit: product.product_template.profit * 3, template_variant: t2)
CalculateOrder.new(order).call
Payment.create!(payable: order, payment_status: 'completed', payment_type: 'paypal')
RecalculateCounters.new.perform

puts 'Order/Payment created'
