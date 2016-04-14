class StripePayment
  def call
    pay
  end

  private

  attr_accessor :payment, :order

  def initialize(payment)
    @payment = payment
    @order = @payment.payable
  end

  def pay
    customer = Stripe::Customer.create email: order.email,
                                       card: payment.payment_token

    Stripe::Charge.create customer: customer.id,
                          amount: (order.total_cost * 100).to_i,
                          currency: 'usd',
                          metadata: { 'order_id' => order.id }

    NotifyDesigners.new(order).call
    FindOrCreateInvoice.new(order).call
    order.update_attributes(purchased: true, purchased_at: DateTime.now, active: false)
    payment.update_attribute(:payment_status, 'completed')
  rescue Stripe::InvalidRequestError => e
    { errors: { base: [e.message] } }
  rescue Stripe::CardError => e
    { errors: { base: [e.message] } }
  end
end
