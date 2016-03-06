class OrderItem < ActiveRecord::Base
  belongs_to :product, counter_cache: true
  belongs_to :order

  after_create SetOrderItemPrice.new
end
