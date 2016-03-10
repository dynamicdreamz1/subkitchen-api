class AddOrderAddress
  def call
    add_address
  end

  private

  attr_reader :params
  attr_accessor :order

  def initialize(params, order)
    @params = params
    @order = order
  end

  def add_address
    order.update( full_name: params.full_name,
                  address: params.address,
                  city: params.city,
                  zip: params[:zip],
                  region: params.region,
                  country: params.country,
                  email: params.email)
  end
end