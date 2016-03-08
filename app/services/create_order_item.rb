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
    OrderItem.create!(
        product_id: product.id,
        order_id: @order.id,
        size: @params[:size],
        quantity: @params[:quantity],
        product_name: product.name,
        product_description: product.description,
        product_author: product.author
    )
  end
end
