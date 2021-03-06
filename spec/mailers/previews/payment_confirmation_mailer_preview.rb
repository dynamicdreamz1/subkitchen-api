class PaymentConfirmationMailerPreview < ActionMailer::Preview
  def send_invoice
    order = Order.create(purchased_at: DateTime.now)
    invoice = Invoice.create(order: order, line_2: 'SubKitchen')
    options = { order: order, invoice: invoice }
    PaymentConfirmationMailer.notify('test@example.com', options)
  end
end
