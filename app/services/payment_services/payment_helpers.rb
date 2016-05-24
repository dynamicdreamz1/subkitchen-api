module PaymentHelpers
  def send_order_and_create_invoice
    if CheckOrderIfReady.new(order).call
      SendOrder.new(order).call
      FindOrCreateInvoice.new(order).call
    else
      order.update(order_status: :processing)
    end
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