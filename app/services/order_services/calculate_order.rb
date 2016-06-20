class CalculateOrder
  def call
    update_order
  end

  private

  attr_accessor :order
	attr_reader :subtotal

  def initialize(order)
    @order = order
		@subtotal = subtotal_cost
  end

  def update_order
		order.discount      = discount
		order.subtotal_cost = new_subtotal
    order.tax_cost      = order.subtotal_cost * order.tax.to_d * 0.01
    order.total_cost    = new_total
    order.save!
  end

	def new_total
		total = order.subtotal_cost + order.tax_cost
		total += order.shipping_cost.to_d unless order.subtotal_cost.zero?
		total
	end

	def discount
		order.coupon ? CalculateDiscount.new(subtotal, order.coupon).call : 0
	end

	def subtotal_cost
    subtotal_cost = 0
    order.order_items.each { |item| subtotal_cost += item.quantity * item.price }
    subtotal_cost
	end

	def new_subtotal
		(order.discount >= subtotal) ? 0 : (subtotal - order.discount)
	end
end
