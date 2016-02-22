class ProductSerializer
  def self.serialize(product)
    { id: product.id,
      author: product.author.name,
      type: product.product_template.product_type,
      price: product.product_template.price.to_s,
      size: product.product_template.size,
      description: product.description,
      name: product.name,
      shipping: product.product_template.shipping.shipping_info,
      size_chart: product.product_template.size_chart_url }
  end
end
