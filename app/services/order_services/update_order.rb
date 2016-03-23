class UpdateOrder
  def call
    update_order
  end

  private

  def initialize(order)
    @order = order
  end

  def update_order
    subtotal_cost = 0
    @order.order_items.each{ |item| subtotal_cost += item.quantity * item.price }
    @order.subtotal_cost = subtotal_cost
    @order.tax_cost = @order.subtotal_cost * @order.tax.to_d * 0.01
    @order.total_cost = @order.subtotal_cost + @order.tax_cost
    @order.total_cost += @order.shipping_cost.to_d if @order.total_cost > 0
    @order.save
  end
end