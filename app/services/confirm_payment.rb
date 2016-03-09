class ConfirmPayment
  def call
    update_order
  end

  private

  attr_accessor :payment, :params, :order

  def initialize(payment, params)
    @payment = payment
    @params = params
    @order = payment.payable
  end

  def update_order
    Order.transaction do
      payment.update(payment_token: params.txn_id, payment_status: 'completed')
      if CheckOrderIfReady.new(order).call
        SendOrder.new(order).call
      else
        order.update(order_status: 'processing')
      end
      order.update(purchased_at: DateTime.now,
                   purchased: true,
                   active: false)
      SalesAndEarningsCounter.perform_async(order.id)
    end
    payment
  end
end