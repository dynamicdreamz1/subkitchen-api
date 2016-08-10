class DenyPayment
  def call
    deny_payment
  end

  private

  attr_accessor :payment, :order

  def initialize(payment)
    @payment = payment
    @order = payment.payable
  end

  def deny_payment
    Order.transaction do
      payment.update(payment_status: 0)
      order.update(order_status: 5, active: false)
      payment
    end
  end
end
