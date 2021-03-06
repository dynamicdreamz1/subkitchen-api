class ApplyCoupon
	include Grape::DSL::InsideRoute

  def call
		error!({ errors: { coupon: ['Coupon already applied'] } }, 422) if coupon_applied?
		error!({ errors: { coupon: ['Coupon invalid'] } }, 404) unless coupon
		error!({ errors: { coupon: ['Coupon expired'] } }, 422) unless redeemable?
    order.update(coupon: coupon)
    recalculate_order if order.order_items.any?
  end

  private

  attr_reader :coupon
  attr_accessor :order

  def initialize(order, coupon_code)
    @order = order
    @coupon = Coupon.find_by(code: coupon_code)
  end

  def recalculate_order
		order.discount = CalculateDiscount.new(order.subtotal_cost, coupon).call
		order.subtotal_cost = order.subtotal_cost - order.discount
		order.tax_cost = order.subtotal_cost * order.tax.to_d * 0.01
		order.total_cost = total_cost
		order.save!
	end

	def coupon_applied?
		order.coupon != nil
	end

  def total_cost
    order.subtotal_cost + order.tax_cost + order.shipping_cost.to_d
  end

  def expired?
    coupon.valid_until <= DateTime.now
  end

  def redeemable?
    !expired? && has_available_redemptions? && started?
  end

  def has_available_redemptions?
    coupon.redemptions_count.zero? || coupon.redemptions_count < coupon.redemption_limit
  end

  def started?
		coupon.valid_from.utc < DateTime.now.utc
  end
end
