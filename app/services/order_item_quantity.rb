class OrderItemQuantity
  def decrement
    @order_item.quantity -= 1
    @order_item.save
  end

  def increment
    @order_item.quantity += 1
    @order_item.save
  end

  private

  def initialize(order_item)
    @order_item = order_item
  end
end