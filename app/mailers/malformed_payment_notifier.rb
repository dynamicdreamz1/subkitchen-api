class MalformedPaymentNotifier < ApplicationMailer

  KEYS = ['PAYMENT_ID', 'PAYMENT_URL']

  KEYS.each do |key|
    define_method("replace_#{key.downcase}") do |content, values|
      content.gsub!(key, values[key.downcase])
    end
  end

  def self.notify(payment)
    emails = AdminUser.pluck(:email)
    emails.each do |email|
      notify_single(email, payment).deliver_later
    end
  end

  def notify_single(admin_email, payment=nil)
    template = EmailTemplate.where(name: 'admin_malformed_payment').first
    content = template.content
    payment_id = payment.id || 1
    values = { 'payment_id' => "#{payment_id}", 'payment_url' => "#{Figaro.env.frontend_host}admin/payments/#{payment_id}"}

    KEYS.each do |key|
      send("replace_#{key.downcase}", content, values)
    end

    mail(to: admin_email,
         body: content,
         content_type: 'text/html',
         subject: template.subject)
  end
end