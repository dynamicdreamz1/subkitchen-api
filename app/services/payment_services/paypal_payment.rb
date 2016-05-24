class PaypalPayment
  def call
    update_order
    update_payment
    send_order_and_create_invoice
    NotifyDesigners.new(order).call
    SalesAndEarningsCounter.perform_async(order.id)
    payment
  end

  private

  include PaymentHelpers

  attr_accessor :payment, :order
  attr_reader :token

  def initialize(payment, params)
    @payment = payment
    @token = params.txn_id
    @order = payment.payable
  end
end
