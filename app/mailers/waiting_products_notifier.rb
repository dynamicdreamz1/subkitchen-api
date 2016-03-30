class WaitingProductsNotifier < ApplicationMailer

  KEYS = ['PRODUCTS_LIST']

  KEYS.each do |key|
    define_method("replace_#{key.downcase}") do |content, values|
      content.gsub!(key, values[key.downcase])
    end
  end

  def self.notify(products)
    emails = Config.designers.strip.split(';')
    emails.each do |email|
      notify_single(email, products.to_a).deliver_later
    end
  end

  def notify_single(email, products=nil)
    products = products || Product.all.limit(3)
    template = EmailTemplate.where(name: 'designer_waiting_products').first

    values = { 'products_list' => products_list(products) }
    content = template.content

    KEYS.each do |key|
      send("replace_#{key.downcase}", content, values)
    end

    mail to: email,
         body: content,
         content_type: 'text/html',
         subject: template.subject
  end

  def products_list(products)
    returns = ""

    products.each.with_index do |product, index|
      returns << "#{index+1}. <a href=\"#{admin_product_url(product)}\">#{product.name}</a><br/>"
    end

    returns
  end
end
