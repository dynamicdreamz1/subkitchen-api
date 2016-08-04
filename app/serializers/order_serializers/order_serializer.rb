class OrderSerializer
  include ApplicationHelper

  def as_json(options = {})
    data = { order:
                 { uuid: order.uuid,
                   user_id: (order.user ? order.user_id : nil),
                   subtotal: order.subtotal_cost,
                   shipping_cost: order.shipping_cost,
                   tax: order.tax,
                   tax_cost: order.tax_cost,
                   total_cost: order.total_cost,
                   discount: order.discount,
                   invoice_id: "#{order.id}/#{order.created_at.strftime('%d/%m/%Y')}",
                   items: items } }

    if order.invoice
      data[:order][:pdf] = Figaro.env.app_host + "/api/v1/invoices?uuid=#{order.uuid}"
      data[:order][:placed] = order.invoice.created_at.strftime('%B %d, %Y - %I:%M %p %Z').to_s
    end
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
        price: item.price,
        name: item.product.name,
        product_id: item.product.id,
        quantity: item.quantity,
        size: item.size,
        preview_url: Figaro.env.app_host + Refile.attachment_url(item.product, :preview, format: :jpg)
      }
    end
  end
end
