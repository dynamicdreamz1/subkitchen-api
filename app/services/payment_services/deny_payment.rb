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
      payment.update(payment_status: 'denied')
      order.update(order_status: 'failed', active: false)
      payment
    end
  end
end
