class ProductSerializer
  def self.serialize(product)
    { author: product.author.name,
      type: product.product_template.product_type,
      price: product.product_template.price,
      size: product.product_template.size,
      description: product.description,
      name: product.name,
      shipping: product.product_template.shipping.info,
      size_chart: product.product_template.size_chart_url }
  end
end