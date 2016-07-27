require 'concerns/email_key_replacer'

class OrderConfirmationMailer < ApplicationMailer
  KEYS = { 'PRODUCT_ROW' => ' (required) - we will place product list here',
           'ORDER_NUMBER' => ' (required) - order number',
           'SUBTOTAL_COST' => ' (required) - order subtotal',
           'SHIPPING_COST' => ' (required) - shipping cost',
           'ORDER_TOTAL_COST' => ' (required) - order total',
           'LOGO_IMG' => ' - logo png file' }.freeze

  PRODUCT_KEYS = { 'PRODUCT_IMG'      => '',
                   'PRODUCT_URL'      => '',
                   'PRODUCT_NAME'     => '',
                   'PRODUCT_SIZE'     => '',
                   'PRODUCT_QUANTITY' => '',
                   'PRODUCT_PRICE'    => '' }.freeze

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
      'subtotal_cost'    => order.subtotal_cost.to_s,
      'shipping_cost'    => order.shipping_cost.to_s,
      'order_total_cost' => order.total_cost.to_s,
      'logo_img'         => attachments['logo.png'].url }
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
      <tr class="product-row">
        <td> <img src="PRODUCT_IMG" width="72" height="72"/> </td>
        <td>
          <p>
            <a href="PRODUCT_URL" target="_blank"> PRODUCT_NAME </a>
            <br>
            Size: PRODUCT_SIZE
            <br>
            Quantity: PRODUCT_QUANTITY
            <br>
            Price: PRODUCT_PRICE
          </p>
        </td>
      </tr>
    EOS
  end

  def product_values(order_item)
    product = order_item.product

    { 'product_img'      => product_preview(product),
      'product_url'      => product_url(product.id),
      'product_name'     => product.name,
      'product_size'     => order_item.size.upcase,
      'product_quantity' => order_item.quantity,
      'product_price'    => order_item.price }
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
