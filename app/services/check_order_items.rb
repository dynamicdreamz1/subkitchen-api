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
      if item.product
        true
      else
        return false
      end
    end
  end
end