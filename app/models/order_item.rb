class OrderItem < ActiveRecord::Base
  belongs_to :product
  belongs_to :order
  after_create :set_price

  def set_price
    update_attribute(:price, product.price) if product
  end
end
