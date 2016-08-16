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
    order_items_count = order.
      order_items.
      count

    product_variants_count = order.
      order_items.
      joins(:product, :product_variants).
      where('product_variants.size = order_items.size').
      where.not(product_variants: { design_id: nil }).
      count

    order_items_count == product_variants_count
  end
end
