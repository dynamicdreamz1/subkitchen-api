class CalculateOrder
  def call
    update_order
  end

  private

  attr_accessor :order

  def initialize(order)
    @order = order
  end

  def update_order
    order.subtotal_cost = order.coupon ? subtotal_with_discount : subtotal_cost
    order.tax_cost = order.subtotal_cost * order.tax.to_d * 0.01
    order.total_cost = total_cost
    order.save
  end

  def subtotal_cost
    subtotal_cost = 0
    order.order_items.each { |item| subtotal_cost += item.quantity * item.price }
    subtotal_cost
  end

  def subtotal_with_discount
    discount = CalculateDiscount.new(subtotal_cost, order.coupon).call
    (discount >= subtotal_cost) ? 0 : (subtotal_cost - discount)
  end

  def total_cost
    total = order.subtotal_cost + order.tax_cost
    total += order.shipping_cost.to_d unless order.subtotal_cost.zero?
    total
  end
end
