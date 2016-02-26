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
                   subtotal: order.subtotal,
                   shipping: order.shipping,
                   tax: order.tax,
                   total: order.total,
                   payment_status: order.payment.status,
                   items: items }}
    if order.user
      data.merge(
          { shipping_address:
               { email: order.user.email,
                 first_name: order.user.first_name,
                 last_name: order.user.last_name,
                 address: order.user.address,
                 city: order.user.city,
                 zip: order.user.zip,
                 region: order.user.region,
                 country: order.user.country,
                 phone: order.user.phone }})
    end

    data[:errors] = order.errors if order.errors.any?

    data.as_json(options)
  end

  private

  attr_reader :order

  def initialize(order)
    @order = order
  end
end
