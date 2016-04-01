require 'http'

class SendOrder
  def call
    send_order
  end

  private

  attr_accessor :order

  def initialize(order)
    @order = order
  end

  def send_order
    order.update(order_status: 'cooking')
    serialized_order = Through6Serializer.new(order).as_json
    HTTP.basic_auth(:user => 'subkitchen', :pass => 'Pass1word').post(Figaro.env.t6_endpoint, json: serialized_order)
  end
end