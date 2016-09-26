require 'concerns/email_key_replacer'

class OrderFulfilledMailer < ApplicationMailer
  KEYS = { 'PRODUCT_ROW' => ' (required) - we will place product list here',
           'ORDER_NUMBER' => ' (required) - order number',
           'SHIPMENT_URL' => '(required) - shipment url',
           'STORE_WEBSITE' => '(required) - store website'
          }.freeze

  PRODUCT_KEYS = { 'PRODUCT_IMG'      => '',
                   'PRODUCT_NAME'     => '',
                   'PRODUCT_TYPE'    => '' }.freeze

  include EmailKeyReplacer

  def notify(email, options = {})
    template = EmailTemplate.where(name: self.class.name.to_s).first
    content = template.content

    replace_keys(content, values(options))

    mail(to: email, subject: template.subject ) do |format|
      format.html { render html: content.html_safe }
    end
  end

  private

  def values(options)
    order = options[:order]
    { 'product_row'      => products_rows(order),
      'order_number'     => order.id.to_s,
      'shipment_url'     => order.shipstation_url.blank? ? "#" : order.shipstation_url.to_s,
      'store_website'    => 'https://www.sublimation.kitchen/' }
  end

  def products_rows(order)
    products_rows = []
    order.order_items.each do |order_item|
      row = empty_product_row.clone
      replace_product_keys(row, product_values(order_item))
      products_rows << row
    end
    products_rows.join
  end

  def empty_product_row
    <<-EOS
      <div class="singleitems">
        <div class="item-img" style=" width: 6%; float: left; border: 1px solid #eee; padding: 5px; border-radius: 10px;" >
          <img style="width: 100%;" src="PRODUCT_IMG">
        </div>
        <div class="item-detail" style="width: 85%; float: left; margin-left: 3%;">
          <h4 style=" margin-bottom: 0; color: #4d4d4d; margin-top: 15px;">PRODUCT_NAME</h4>
          <p style="margin-top: 0; color: #8d8d8d;">PRODUCT_TYPE</p>
        </div>
      </div>
    EOS
  end

  def product_values(order_item)
    product = order_item.product

    { 'product_img'      => product_preview(product),
      'product_name'     => product.name,
      'product_type'     => product.try(:product_template).try(:product_type) }
  end

  def product_preview(product)
    Figaro.env.app_host + Refile.attachment_url(product, :preview, format: :png)
  end

  def product_url(product_id)
    "#{Figaro.env.frontend_host}products/#{product_id}"
  end

  def replace_product_keys(content, values)
    self.class::PRODUCT_KEYS.keys.each do |key|
      send("replace_#{key.downcase}", content, values)
    end
  end

  PRODUCT_KEYS.keys.each do |key|
    define_method("replace_#{key.downcase}") do |content, values|
      content.gsub!(key, values[key.downcase].to_s)
    end
  end
end
