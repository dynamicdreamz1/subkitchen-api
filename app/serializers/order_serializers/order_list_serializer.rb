class OrderListSerializer
  include ApplicationHelper

  def as_json(options = {})
    data = { orders: serialized_orders }
    data.as_json(options)
  end

  private

  attr_accessor :orders

  def initialize(order_list)
    @orders = order_list
  end

  def serialized_orders
    orders.map do |order|
      single_order = single_order(order)

      if order.invoice
        single_order[:pdf] = Figaro.env.app_host + "/api/v1/invoices?uuid=#{order.uuid}"
        single_order[:placed] = order.invoice.created_at.strftime('%B %d, %Y - %I:%M %p %Z').to_s
      end
      single_order[:errors] = order.errors if order.errors.any?
      single_order
    end
  end

  def single_order(order)
    {
      id: order.id,
      uuid: order.uuid,
      created_at: order.created_at,
			paypal_url: order.paypal_url,
      status: order.order_status,
      total_cost: order.total_cost,
      invoice_id: "#{order.id}/#{order.created_at.strftime('%d/%m/%Y')}"
    }
  end
end
