require 'concerns/email_key_replacer'

class WaitingProductsNotifier < ApplicationMailer
  include EmailKeyReplacer

  KEYS = ['PRODUCTS_LIST']

  def self.notify(products)
    emails = Config.designers.strip.split(';')
    emails.each do |email|
      notify_single(email, products.to_a).deliver_later
    end
  end

  def notify_single(email, products=nil)
    template = EmailTemplate.where(name: "#{self.class.name}").first
    content = template.content

    replace_keys(content, values(products))

    mail to: email,
         body: content,
         content_type: 'text/html',
         subject: template.subject
  end

  def self.keys
    ["PRODUCTS_LIST (required) - list of all products (by names) that are waiting for designs"]
  end

  private

  KEYS.each do |key|
    define_method("replace_#{key.downcase}") do |content, values|
      content.gsub!(key, values[key.downcase])
    end
  end

  def products_list(products)
    returns = ""

    products.each.with_index do |product, index|
      returns << "#{index+1}. <a href=\"#{admin_product_url(product)}\">#{product.name}</a><br/>"
    end

    returns
  end

  def values(products)
    if products
      products
    else
      products = Product.all.limit(3)
    end
    {
        'products_list' => products_list(products)
    }
  end
end
