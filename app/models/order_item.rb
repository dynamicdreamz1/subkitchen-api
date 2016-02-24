class OrderItem < ActiveRecord::Base
  belongs_to :product
  belongs_to :order
  after_create :set_price

  def set_price
    update_attribute(:price, product.price) if product
  end

  def increment
    self.quantity += 1
    self.save
  end

  def decrement
    self.quantity -= 1
    self.save
  end
end
