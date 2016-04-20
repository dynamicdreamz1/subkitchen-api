class CreatePayment
  def call
    create_payment
  end

  private

  attr_accessor :order
  attr_reader :payment_type, :payment_token, :return_path

  def initialize(order, payment_type, payment_token, return_path)
    @order = order
    @payment_type = payment_type
    @payment_token = payment_token
    @return_path = return_path
  end

  def create_payment
    order.update(order_status: 'payment pending')
    return false if already_paid?
    payment = Payment.create!(payable: order, payment_type: payment_type)
    if payment_type == 'stripe'
      payment.update(payment_token: payment_token)
      payment.save
      StripePayment.new(payment).call
    else
      url = PaypalPayment.new(payment, return_path).call
      { url: url }
    end
  end

  def already_paid?
    Payment.find_by(payable: order, payment_status: 'completed')
  end
end
