class StripePayment
  def call
    charge
    update_order
    update_payment
    send_order_and_create_invoice
    NotifyDesigners.new(order).call
    SalesAndEarningsCounter.perform_async(order.id)
    payment
    rescue Stripe::InvalidRequestError => e
      { errors: { base: [e.message] } }
    rescue Stripe::CardError => e
      { errors: { base: [e.message] } }
  end

  private

  include PaymentHelpers

  attr_accessor :payment, :order
  attr_reader :token

  def initialize(payment, payment_token)
    @payment = payment
    @order = @payment.payable
    @token = payment_token
  end

  def charge
    customer = Stripe::Customer.create email: order.email,
                                       card: payment.payment_token
    Stripe::Charge.create customer: customer.id,
                          amount: (order.total_cost * 100).to_i,
                          currency: 'usd',
                          metadata: { 'order_id' => order.id }
  end
end