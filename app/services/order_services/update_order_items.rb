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
      items << item if item.product.is_deleted
    end
    OrderItem.destroy(items.map(&:id))
    @order.order_items.reload
    CalculateOrder.new(@order).call
    CheckoutSerializer.new(@order, items).as_json
  end
end
