class ProductSerializer
  def as_json(options={})
    data = { id: product.id,
      author: product.author.name,
      price: product.product_template.price.to_s,
      size: product.product_template.size,
      description: product.description,
      name: product.name,
      likes: product.likes,
      product_image: product.image_url,
      shipping: Config.shipping_info,
      shipping_cost: Config.shipping_cost,
      tax: Config.tax,
      size_chart: product.product_template.size_chart_url }

    data[:errors] = product.errors if product.errors.any?

    data.as_json(options)
  end

  private

  attr_reader :product

  def initialize(product)
    @product = product
  end
end
