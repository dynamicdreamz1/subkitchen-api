class CommonPayment
  def call
    update_order
    update_payment
    send_order_and_create_invoice
    SalesAndEarningsCounter.perform_async(order.id)
    PaymentConfirmationMailer.notify(order.email, invoice: order.invoice, order: order)
    payment
  end

  private

  attr_accessor :payment, :order
  attr_reader :token

  def initialize(payment, payment_token)
    @payment = payment
    @order = @payment.payable
    @token = payment_token
  end

  def send_order_and_create_invoice
    FindOrCreateInvoice.new(order).call
    status = if CheckOrderIfReady.new(order).call
               SendOrder.new(order).call
               'cooking'
             else
               NotifyDesigners.new(order).call
               'processing'
             end
    order.update(order_status: status)
  end

  def update_order
    order.update(purchased_at: DateTime.now,
                 purchased: true,
                 active: false)
  end

  def update_payment
    payment.update(payment_token: token, payment_status: :completed)
  end
end
