class OrderItem < ActiveRecord::Base
  belongs_to :product
  belongs_to :order

  def increment
    self.quantity += 1
    self.save
  end

  def decrement
    self.quantity -= 1
    self.save
  end
end
