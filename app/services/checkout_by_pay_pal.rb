class CheckoutByPayPal
  def call
    return false if already_paid?
    payment = Payment.create(payable: order, payment_status: 'pending')
    url = PaypalPayment.new(payment, params.return_path).call
    { url: url }
  end

  private

  attr_accessor :order, :params

  def initialize(order, params)
    @order = order
    @params = params
  end

  def already_paid?
    Payment.find_by(payable: order, payment_status: 'completed')
  end
end
