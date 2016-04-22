class PaypalPayment
  def call
    update_order
    update_payment
    send_order_and_create_invoice
    NotifyDesigners.new(order).call
    SalesAndEarningsCounter.perform_async(order.id)
    RedemptionsCounter.perform_async(order.coupon.id) if order.coupon
    payment
  end

  private

  attr_accessor :payment, :params, :order

  def initialize(payment, params)
    @payment = payment
    @params = params
    @order = payment.payable
  end

  def send_order_and_create_invoice
    if CheckOrderIfReady.new(order).call
      SendOrder.new(order).call
      FindOrCreateInvoice.new(order).call
    else
      order.update(order_status: 'processing')
    end
  end

  def update_order
    order.update(purchased_at: DateTime.now,
                 purchased: true,
                 active: false)
  end

  def update_payment
    payment.update(payment_token: params.txn_id, payment_status: 'completed')
  end
end
