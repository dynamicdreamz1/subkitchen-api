class CreateOrderItem
  def call
    create
  end

  private

  def initialize(product_id, order, params)
    @product_id = product_id
    @order = order
    @params = params
  end

  def create
    product = Product.find_by(id: @product_id)
    template = product.product_template
    OrderItem.create!(
      product_id: product.id,
      order_id: @order.id,
      size: @params[:size],
      style: template.style,
      quantity: @params[:quantity],
      template_variant_id: @params[:template_variant_id]
    )
  end
end
