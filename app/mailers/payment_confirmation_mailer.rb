require 'concerns/email_key_replacer'

class PaymentConfirmationMailer < ApplicationMailer
  def notify(email, options = {})
    template = EmailTemplate.where(name: self.class.name.to_s).first
    content = template.content

    add_invoice(options)

    mail(to: email, subject: template.subject) do |format|
      format.html { render html: content.html_safe }
    end
  end

  private

  def add_invoice(options)
    invoice = InvoicePdf.new(options[:invoice])
    attachments["order_#{options[:order].id}_#{options[:order].purchased_at.strftime('%d_%m_%Y')}.pdf"] = { mime_type: 'application/pdf', content: invoice.render }
  end
end
