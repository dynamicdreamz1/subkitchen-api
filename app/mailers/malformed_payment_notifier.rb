require 'concerns/email_key_replacer'

class MalformedPaymentNotifier < ApplicationMailer
  KEYS = {'PAYMENT_ID' => ' (required) - admin url for the malformed payment',
          'PAYMENT_URL' => ' - malformed payment id'}
  include EmailKeyReplacer

  def notify(recipients, payment)
    template = EmailTemplate.where(name: "#{self.class.name}").first
    content = template.content

    replace_keys(content, values(payment))

    mail(to: recipients,
         body: content,
         content_type: 'text/html',
         subject: template.subject)
  end

  private

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