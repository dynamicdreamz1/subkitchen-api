class OrderItemQuantity
  def call
    change_quantity
  end

  private

  def initialize(order_item, quantity)
    @order_item = order_item
    @quantity = quantity
  end

  def change_quantity
    @order_item.quantity += @quantity
    @order_item.save
  end
end