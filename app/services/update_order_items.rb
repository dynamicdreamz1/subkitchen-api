class UpdateOrderItems
  def call
    update_order
  end

  private

  def initialize(order)
    @order = order
  end

  def update_order
    items = []
    @order.order_items.each do |item|
      item.product ? true : items << item
    end
    OrderItem.destroy(items.map{ |i| i.id })
    @order.order_items.reload
    { order_items: @order.order_items, deleted_items: items }
  end
end