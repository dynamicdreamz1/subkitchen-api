require 'concerns/email_key_replacer'

class OrderConfirmationMailer < ApplicationMailer
  def notify(email, options = {})
    template = EmailTemplate.where(name: self.class.name.to_s).first
    content = template.content

    invoice = InvoicePdf.new(options[:invoice])
    attachments["order_#{options[:order].id}_#{options[:order].purchased_at.strftime('%d_%m_%Y')}.pdf"] = { mime_type: 'application/pdf', content: invoice.render }

    mail to: email,
         body: content,
         content_type: 'text/html',
         subject: template.subject
  end
end
