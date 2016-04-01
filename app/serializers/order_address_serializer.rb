class OrderAddressSerializer
  def as_json(options = {})
    data = {
        full_name: order.full_name,
        address: order.address,
        city: order.city,
        zip: order.zip,
        region: order.region,
        country: order.country,
        email: order.email
    }

    data[:errors] = user.errors if user.errors.any?

    { customer_information: data }.as_json(options)
  end

  private

  attr_reader :order

  def initialize(order)
    @order = order
  end
end
