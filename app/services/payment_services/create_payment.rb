class CreatePayment
  def call
    return false if already_paid?
    update_order
    charge
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

  def already_paid?
    Payment.find_by(payable: order, payment_status: 'completed')
  end

  def update_order
    order.update(order_status: 'payment_pending')
  end

  def charge
    payment = find_or_create_payment
    if payment.payment_type == 'stripe'
      StripePayment.new(payment, payment_token).call
		else
			if order.paypal_url
      	url = order.paypal_url
			else
				url = PaypalPaymentRequest.new(payment, return_path).call
				order.update(paypal_url: url)
			end
      { url: url }
    end
	end

	def find_or_create_payment
		Payment.find_by(payable: order) || Payment.create!(payable: order, payment_type: payment_type)
	end
end
