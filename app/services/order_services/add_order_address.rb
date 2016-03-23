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
    order.full_name = params.full_name
    order.city      = params.city
    order.address   = params.address
    order.zip       = params[:zip]
    order.region    = params.region
    order.country   = params.country
    order.email     = params.email

    order.save(context: :address)
  end
end
