class CheckoutSerializer
  include ApplicationHelper

  def as_json(options={})
    data = { order:
                 { uuid: order.uuid,
                   purchased_at: order.purchased_at,
                   status: order.order_status,
                   subtotal: order.subtotal_cost,
                   shipping_cost: order.shipping_cost,
                   tax: order.tax,
                   tax_cost: order.tax_cost,
                   total_cost: order.total_cost,
                   items: items,
                   pdf: Figaro.env.app_host+"api/v1/invoices?uuid=#{order.uuid}" }}
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
      { price: item.price,
        subtotal: item.price*item.quantity,
        name: item.product.name,
        id: item.id,
        is_deleted: item.product.is_deleted,
        quantity: item.quantity,
        size: item.size,
        image: Figaro.env.app_host + Refile.attachment_url(item.product, :image, format: :png)}
    end
  end

  def deleted_items
    @deleted_items.map do |item|
      { price: item.price,
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
