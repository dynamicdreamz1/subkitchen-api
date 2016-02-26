class OrderSerializer
  def as_json(options={})
    items = order.order_items.map do |item|
      { price: item.price,
        name: item.product.name,
        id: item.id,
        quantity: item.quantity,
        size: item.size,
        image: item.product.image}
    end
    data = { order:
                 { uuid: order.uuid,
                  purchased_at: order.purchased_at,
                  status: order.status,
                  subtotal: order.subtotal_cost,
                  shipping_cost: order.shipping_cost,
                  tax: order.tax,
                  tax_cost: order.tax_cost,
                  total: order.total_cost,
                  payment_status: order.payment.status,
                  items: items,
                  shipping_address: {
                      first_name: order.first_name,
                      last_name: order.last_name,
                      address: order.address,
                      city: order.city,
                      zip: order.zip,
                      region: order.region,
                      country: order.country,
                      phone: order.phone }}}

    data[:errors] = order.errors if order.errors.any?

    data.as_json(options)
  end

  private

  attr_reader :order

  def initialize(order)
    @order = order
  end
end
