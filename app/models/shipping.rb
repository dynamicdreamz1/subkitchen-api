class Shipping < ActiveRecord::Base
  has_many :product_templates
  has_many :orders
end
