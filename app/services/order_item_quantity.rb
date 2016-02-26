class OrderItemQuantity
  def decrement
    @order_item.quantity -= 1
    @order_item.save
    @order_item
  end

  def increment
    @order_item.quantity += 1
    @order_item.save
    @order_item
  end

  private

  def initialize(order_item)
    @order_item = order_item
  end
end