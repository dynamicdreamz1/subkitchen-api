require 'concerns/email_key_replacer'

class MalformedPaymentNotifier < ApplicationMailer
  KEYS = { 'PAYMENT_ID' => ' (required) - admin url for the malformed payment',
           'PAYMENT_URL' => ' - malformed payment id' }.freeze
  include EmailKeyReplacer

  def notify(recipients, options = {})
    template = EmailTemplate.where(name: self.class.name.to_s).first
    content = template.content

    replace_keys(content, values(options))

    mail(to: recipients,
         body: content,
         content_type: 'text/html',
         subject: template.subject)
  end

  private

  def values(options)
    payment_id = options[:payment_id] || 1
    { 'payment_id' => payment_id.to_s,
      'payment_url' => payment_url(payment_id) }
  end

  def payment_url(payment_id)
    File.join(Figaro.env.frontend_host, 'admin/payments', payment_id.to_s)
  end
end
