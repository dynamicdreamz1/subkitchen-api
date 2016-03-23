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
    #send order to through6
  end
end