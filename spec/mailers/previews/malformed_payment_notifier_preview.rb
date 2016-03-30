class MalformedPaymentNotifierPreview < ActionMailer::Preview
  def malformed_payment
    payment = Payment.create
    MalformedPaymentNotifier.notify('test@email.com', payment)
  end
end
