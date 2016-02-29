class CreateOrderItem
  def call
    create
  end

  private

  def initialize(product, order, params)
    @product = product
    @order = order
    @params = params
  end

  def create
    OrderItem.create!(
        product_id: @product.id,
        order_id: @order.id,
        size: @params[:size],
        product_name: @product.name,
        product_description: @product.description,
        product_author: @product.author
    )
  end
end