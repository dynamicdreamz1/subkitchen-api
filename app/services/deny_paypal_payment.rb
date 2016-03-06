class DenyPaypalPayment
  def call
    deny_payment
  end

  private

  attr_accessor :payment, :params, :order

  def initialize(payment, params)
    @payment = payment
    @params = params
    @order = payment.payable
  end

  def deny_payment
    Order.transaction do
      payment.update(payment_status: 'denied')
      order.update(order_status: 'creating')
      payment
    end
  end
end