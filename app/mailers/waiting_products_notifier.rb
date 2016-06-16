require 'concerns/email_key_replacer'

class WaitingProductsNotifier < ApplicationMailer
  KEYS = { 'PRODUCTS_LIST' => '(required) - list of all products (by names) that are waiting for designs' }.freeze
  include EmailKeyReplacer

  def notify(recipients, options = {})
    template = EmailTemplate.where(name: self.class.name.to_s).first
    content = template.content

    replace_keys(content, values(options))

    mail(to: recipients, subject: template.subject ) do |format|
      format.html { render html: content.html_safe }
    end
  end

  private

  def products_list(products)
    list = ''
    products.each.with_index do |product, index|
      list << "#{index + 1}. <a href=\"#{admin_product_url(product)}\">#{product.name}</a><br/>"
    end
    list
  end

  def values(options)
    { 'products_list' => products_list(options[:products] || Product.last(3)) }
  end
end
