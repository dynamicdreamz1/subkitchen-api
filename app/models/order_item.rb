class OrderItem < ActiveRecord::Base
  belongs_to :product, counter_cache: true
  belongs_to :order

  after_create SetOrderItem.new

  def product
    Product.unscoped.find_by_id(product_id)
  end
end
