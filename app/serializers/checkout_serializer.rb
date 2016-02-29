class CheckoutSerializer
  def as_json(options={})
    items = order.order_items.map do |item|
      { price: item.price,
        name: item.product_name,
        id: item.id,
        quantity: item.quantity,
        size: item.size,
        image: item.product.image_url}
    end

    if deleted_items
      deleted = deleted_items.map do |item|
        { price: item.price,
          name: item.product_name,
          id: item.id,
          quantity: item.quantity,
          size: item.size }
      end
    end
    data = { order:
                 { uuid: order.uuid,
                   status: order.status,
                   subtotal: order.subtotal_cost,
                   shipping_cost: order.shipping_cost,
                   tax: order.tax,
                   tax_cost: order.tax_cost,
                   total_cost: order.total_cost,
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
    data[:deleted_items] = deleted if deleted_items

    data.as_json(options)
  end

  private

  attr_reader :order, :deleted_items

  def initialize(order, deleted_items=nil)
    @order = order
    @deleted_items = deleted_items
  end
end
