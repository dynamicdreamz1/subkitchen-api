class CheckoutSerializer
  include ApplicationHelper

  def as_json(options={})
    data = { order:
                 { uuid: order.uuid,
                   status: order.order_status,
                   subtotal: number_to_price(order.subtotal_cost),
                   shipping_cost: number_to_price(order.shipping_cost),
                   tax: order.tax,
                   tax_cost: number_to_price(order.tax_cost),
                   total_cost: number_to_price(order.total_cost),
                   items: items }}
    data.merge(shipping_address) if order.user

    data[:errors] = order.errors if order.errors.any?
    data[:deleted_items] = deleted_items if @deleted_items

    data.as_json(options)
  end

  private

  attr_accessor :order

  def initialize(order, deleted_items=nil)
    @order = order
    @deleted_items = deleted_items
  end

  def items
    order.order_items
      .reject{|item| item.product.is_deleted}
      .map do |item|
      { price: number_to_price(item.price),
        name: item.product_name,
        id: item.id,
        is_deleted: item.product.is_deleted,
        quantity: item.quantity,
        size: item.size,
        image: Figaro.env.app_host + Refile.attachment_url(item.product, :image, format: :png)}
    end
  end

  def deleted_items
    @deleted_items.map do |item|
      { price: number_to_price(item.price),
        name: item.product.name,
        id: item.id,
        quantity: item.quantity,
        size: item.size,
        image: Figaro.env.app_host + Refile.attachment_url(item.product, :image, format: :png)}
    end
  end

  def shipping_address
    { shipping_address:
      { email: order.user.email,
        first_name: order.user.first_name,
        last_name: order.user.last_name,
        address: order.user.address,
        city: order.user.city,
        zip: order.user.zip,
        region: order.user.region,
        country: order.user.country,
        phone: order.user.phone
      }
    }
  end
end
