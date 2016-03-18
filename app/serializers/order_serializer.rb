class OrderSerializer
  include ApplicationHelper

  def as_json(options={})
    data = {
        order: {
            uuid: order.uuid,
            user_id: (order.user ? order.user_id : nil),
            subtotal: number_to_price(order.subtotal_cost),
            shipping_cost: number_to_price(order.shipping_cost),
            tax: order.tax,
            tax_cost: number_to_price(order.tax_cost),
            total_cost: number_to_price(order.total_cost),
            items: items
        }
    }

    data[:errors] = order.errors if order.errors.any?

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
          price: number_to_price(item.price),
          name: item.product.name,
          product_id: item.product.id,
          quantity: item.quantity,
          size: item.size,
          image: Figaro.env.app_host + Refile.attachment_url(item.product, :image, format: :png)
      }
    end
  end
end

