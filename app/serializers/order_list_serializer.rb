class OrderListSerializer
  include ApplicationHelper

  def as_json(options={})
    data = {
        orders: serialized_orders,
        meta: {
            current_page: orders.current_page,
            total_pages: orders.total_pages
        }
    }

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

      single_order[:errors] = order.errors if order.errors.any?
      single_order
    end
  end

  def single_order(order)
    {
        uuid: order.uuid,
        created_at: order.created_at,
        order_status: order.order_status,
        total_cost: order.total_cost
    }
  end
end