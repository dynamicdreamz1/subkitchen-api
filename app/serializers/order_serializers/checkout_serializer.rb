class CheckoutSerializer
  include ApplicationHelper

  def as_json(options = {})
    data = { order:
             { id: order.id,
               uuid: order.uuid,
               purchased_at: order.purchased_at,
               status: order.order_status,
               subtotal: order.subtotal_cost,
               shipping_cost: order.shipping_cost,
               tax: order.tax,
               tax_cost: order.tax_cost,
               total_cost: order.total_cost,
               discount: order.discount,
               items: items,
               invoice_id: "#{order.id}/#{order.created_at.strftime('%d/%m/%Y')}" } }

    if order.invoice
      data[:order][:pdf] = Figaro.env.app_host + "/api/v1/invoices?uuid=#{order.uuid}"
      data[:order][:placed] = "#{order.invoice.created_at.strftime('%B %d, %Y - %I:%M %p %Z')}"
    end
    data[:order][:shipping_address] = shipping_address if order.address
    data[:errors] = order.errors if order.errors.any?
    data[:deleted_items] = deleted_items if @deleted_items

    data.as_json(options)
  end

  private

  attr_accessor :order

  def initialize(order, deleted_items = nil)
    @order = order
    @deleted_items = deleted_items
  end

  def items
    order.order_items
         .reject { |item| item.product.is_deleted }
         .map do |item|
      { price: item.price,
        subtotal: item.price * item.quantity,
        name: item.product.name,
        id: item.id,
        is_deleted: item.product.is_deleted,
        quantity: item.quantity,
        size: item.size,
        preview_url: Figaro.env.app_host + Refile.attachment_url(item.product, :preview, format: :png),
        product_id: item.product_id}
    end
  end

  def deleted_items
    @deleted_items.map do |item|
      { price: item.price,
        name: item.product.name,
        id: item.id,
        quantity: item.quantity,
        size: item.size,
        preview_url: Figaro.env.app_host + Refile.attachment_url(item.product, :preview, format: :png) }
    end
  end

  def shipping_address
    { email: order.email,
      first_name: full_name.first,
      last_name: full_name[1...-1],
      address: order.address,
      city: order.city,
      zip: order.zip,
      region: order.region,
      country: order.country,
      phone: order.try(:phone)
    }
  end

  def full_name
    order.full_name.split(' ')
  end
end
