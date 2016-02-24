class DecrementOrderItem
  def call
    decrement
  end

  private

  def initialize(order_item)
    @order_item = order_item
  end

  def decrement
    @order_item.quantity -= 1
    @order_item.save
  end
end