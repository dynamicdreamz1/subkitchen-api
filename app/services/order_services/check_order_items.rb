class CheckOrderItems
  def call
    order_items_exist?
  end

  private

  def initialize(order)
    @order = order
  end

  def order_items_exist?
    @order.order_items.each do |item|
      return false if item.product.is_deleted
    end
    true
  end
end
