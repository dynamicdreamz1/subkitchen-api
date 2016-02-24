class IncrementOrderItem
  def call
    increment
  end

  private

  def initialize(order_item)
    @order_item = order_item
  end

  def increment
    @order_item.quantity += 1
    @order_item.save
  end
end