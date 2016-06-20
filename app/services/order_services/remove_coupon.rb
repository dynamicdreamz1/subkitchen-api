class RemoveCoupon

  def call
		order.update!(coupon_id: nil)
		CalculateOrder.new(order).call
  end

  private

  attr_accessor :order

  def initialize(order)
    @order = order
  end
end
