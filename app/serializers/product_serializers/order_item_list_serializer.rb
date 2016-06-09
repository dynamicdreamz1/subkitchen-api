class OrderItemListSerializer

  def as_json(options = {})
    data = {
      order_items: serialized_order_items,
      meta: {
        current_page: order_items.current_page,
        total_pages: order_items.total_pages,
        per_page: order_items.limit_value
      }
    }

    data.as_json(options)
  end

  private

  attr_accessor :order_items

  def initialize(order_items)
    @order_items = order_items
  end

  def serialized_order_items
    order_items.map do |order_item|
      single_order_item = single_order_item(order_item)
      single_order_item[:errors] = order_item.errors if order_item.errors.any?
      single_order_item
    end
  end

  def single_order_item(order_item)
    {
      id: order_item.id,
      price: order_item.price,
      name: order_item.product.name,
      likes_count: order_item.product.likes_count,
      preview_url: product_image(order_item),
      quantity: order_item.quantity,
      product_id: order_item.product_id,
      purchased_at: order_item.order.purchased_at,
      status: order_item.order.order_status
    }
  end

  def product_image(order_item)
    img_key = order_item.product.preview ? :preview : :image
    Figaro.env.app_host.to_s + Refile.attachment_url(order_item.product, img_key, :fill, 400, 400, format: :png)
  end
end
