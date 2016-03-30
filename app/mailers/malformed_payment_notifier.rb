require 'concerns/email_key_replacer'

class MalformedPaymentNotifier < ApplicationMailer
  KEYS = ['PAYMENT_ID', 'PAYMENT_URL']

  include EmailKeyReplacer

  def self.notify(payment)
    emails = AdminUser.pluck(:email)
    emails.each do |email|
      notify_single(email, payment).deliver_later
    end
  end

  def notify_single(admin_email, payment=nil)
    template = EmailTemplate.where(name: "#{self.class.name}").first
    content = template.content

    replace_keys(content, values(payment))

    mail(to: admin_email,
         body: content,
         content_type: 'text/html',
         subject: template.subject)
  end

  def self.keys
    ["PAYMENT_URL (required) - admin url for the malformed payment",
     "PAYMENT_ID - malformed payment id"]
  end

  private

  KEYS.each do |key|
    define_method("replace_#{key.downcase}") do |content, values|
      content.gsub!(key, values[key.downcase])
    end
  end

  def values(payment)
    if payment
      payment_id = payment.id
    else
      payment_id = 1
    end
    {
        'payment_id' => "#{payment_id}",
        'payment_url' => "#{Figaro.env.frontend_host}admin/payments/#{payment_id}"
    }
  end
end