require 'concerns/email_key_replacer'

class MalformedPaymentNotifier < ApplicationMailer
  KEYS = { 'PAYMENT_ID' => ' (required) - admin url for the malformed payment',
          'PAYMENT_URL' => ' - malformed payment id' }
  include EmailKeyReplacer

  def notify(recipients, payment_id)
    template = EmailTemplate.where(name: "#{self.class.name}").first
    content = template.content

    replace_keys(content, values(payment_id || 1))

    mail(to: recipients,
         body: content,
         content_type: 'text/html',
         subject: template.subject)
  end

  private

  def values(payment_id)
    { 'payment_id' => "#{payment_id}",
      'payment_url' => "#{Figaro.env.frontend_host}admin/payments/#{payment_id}" }
  end
end