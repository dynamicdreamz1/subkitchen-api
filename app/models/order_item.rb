class OrderItem < ActiveRecord::Base
  belongs_to :product
  belongs_to :order
  after_create :set_price

  def set_price
    self.price = product.price
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
