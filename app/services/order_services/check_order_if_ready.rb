class CheckOrderIfReady
  def call
    check
  end

  private

  attr_accessor :order

  def initialize(order)
    @order = order
  end

  def check
    !order.order_items.joins(:product).where(products: { design_id: nil }).exists?
  end
end
