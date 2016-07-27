class OrderConfirmationMailerPreview < ActionMailer::Preview
  def send_invoice
    order = Order.create(purchased_at: DateTime.now)
    options = { order: order }
    OrderConfirmationMailer.notify('test@example.com', options)
  end
end
