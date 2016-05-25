class CalculateDiscount
  def call
    calculate_discount
  end

  private

  attr_reader :coupon
  attr_accessor :subtotal

  def initialize(subtotal, coupon)
    @subtotal = subtotal
    @coupon = coupon
  end

  def calculate_discount
    coupon.percentage ? (coupon.discount * 0.01 * subtotal) : coupon.discount
  end
end
