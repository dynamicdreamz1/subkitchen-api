class ProductSerializer
  def self.serialize(product)
    { id: product.id,
      author: product.author.name,
      price: product.product_template.price.to_s,
      size: product.product_template.size,
      description: product.description,
      name: product.name,
      product_image: product.image_url,
      shipping: Config.shipping_info,
      shipping_cost: Config.shipping_cost,
      tax: Config.tax,
      size_chart: product.product_template.size_chart_url }
  end
end
