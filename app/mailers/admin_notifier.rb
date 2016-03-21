class AdminNotifier < ApplicationMailer
  def self.send_malformed_payment_email(payment)
    AdminUser.all.each do |admin|
      malformed_payment(payment, admin).deliver_later
    end
  end

  def malformed_payment(payment, admin)
    @payment = payment
    mail to: admin.email, subject: 'Malformed payment'
  end
end
