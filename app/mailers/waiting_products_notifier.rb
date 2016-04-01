require 'concerns/email_key_replacer'

class WaitingProductsNotifier < ApplicationMailer
  KEYS = { 'PRODUCTS_LIST' => '(required) - list of all products (by names) that are waiting for designs' }
  include EmailKeyReplacer

  def notify(recipients, products)
    template = EmailTemplate.where(name: "#{self.class.name}").first
    content = template.content

    replace_keys(content, values(products))

    mail to: recipients,
         body: content,
         content_type: 'text/html',
         subject: template.subject
  end

  private

  def products_list(products)
    list = ''
    products.each.with_index do |product, index|
      list << "#{index+1}. <a href=\"#{admin_product_url(product)}\">#{product.name}</a><br/>"
    end
    list
  end

  def values(products)
    { 'products_list' => products_list(products || Product.last(3)) }
  end
end
