class Through6Serializer
  include ApplicationHelper

  def as_json(options = {})
    data = {
        'id': order.id,
        'email': order.email,
        'created_at': order.created_at,
        'updated_at': order.updated_at,
        'token': order.uuid,
        'total_price': order.total_cost,
        'subtotal_price': order.subtotal_cost,
        'total_tax': order.tax_cost,
        'taxes_included':false,
        'currency':'USD',
        'total_discounts': nil,
        'processed_at': DateTime.now,
        'tax_lines':[
            {
                'title': 'Tax',
                'price': order.tax_cost,
                'rate': Config.tax.to_d*0.01
            }
        ],
        'shipping_address': [
            'address1': order.address,
            'city': order.city,
            'country': order.country,
            'name': order.full_name,
            'zip': order.zip,
            'province': order.region
        ],
        'line_items': items
    }

    data.as_json(options)
  end

  private

  attr_reader :order

  def initialize(order)
    @order = order
  end

  def items
    order.order_items.map do |item|
      {
          id: item.id,
          name: item.product.name,
          description: item.product.description,
          quantity: item.quantity,
          attributes: { size: item.size },
          unit_amount: item.price,
          subtotal_amount: item.price*item.quantity,
          thumbnail: Figaro.env.app_host + Refile.attachment_url(item.product, :preview, :fill, 100, 100, format: :png),
          preview: Figaro.env.app_host + Refile.attachment_url(item.product, :preview, :fill, 400, 400, format: :png),
          file_url: Figaro.env.app_host + Refile.attachment_url(item.product, :design, format: :pdf),
          file_extension: 'pdf',
          file_type: item.product.design_content_type,
          file_size: item.product.design_size,
          file_hash: item.product.design_id
      }
    end
  end
end