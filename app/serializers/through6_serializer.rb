class Through6Serializer
  include ApplicationHelper

  def as_json(options = {})
    data = {
        type: 'Order',
        version: '1.0',
        time: DateTime.now,
        method: 'create',
        xid: order.uuid,
        status: 'In Production',
        created: order.created_at,
        updated: order.updated_at,
        track_url: Figaro.env.app_host + "api/v1/track?order_uuid=#{order.uuid}",
        receipt_url: Figaro.env.app_host + "api/v1/receipt?order_uuid=#{order.uuid}" ,
        client: 'SublimationKitchen',
        shipping_country: 'US',
        mode: 'auto',
        items_quantity: order.order_items.count,
        items_amount: order.total_cost,
        items: items,
        shipping: shipping
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
          type: 'on-demand',
          code: '',
          name: item.product.name,
          description: item.product.description,
          quantity: item.quantity,
          attributes: { size: item.size },
          unit_amount: number_to_price(item.price),
          subtotal_amount: number_to_price(item.price*item.quantity),
          thumbnail: Figaro.env.app_host + Refile.attachment_url(item.product, :image, :fill, 100, 100, format: :png),
          preview: Figaro.env.app_host + Refile.attachment_url(item.product, :image, :fill, 400, 400, format: :png),
          file_url: Figaro.env.app_host + Refile.attachment_url(item.product, :design, format: :pdf),
          file_extension: 'pdf',
          file_type: item.product.design_content_type,
          file_size: item.product.design_size,
          file_hash: item.product.design_id
      }
    end
  end

  def shipping
    {
        courier: "DHL",
        service: "PLP",
        package: "Bag"
    }
  end
end