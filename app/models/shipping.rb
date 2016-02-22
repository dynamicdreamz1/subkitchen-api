class Shipping < ActiveRecord::Base
  has_many :product_templates
end
