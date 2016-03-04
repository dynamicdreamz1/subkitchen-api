class CreatePayment
  def call
    create_payment
  end

  private

  attr_accessor :order

  def initialize(order)
    @order = order
  end

  def create_payment
    order.update(order_status: 'payment pending')
    Payment.create!(payable: order)
  end
end