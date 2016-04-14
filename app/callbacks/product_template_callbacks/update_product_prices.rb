class UpdateProductPrices
  def after_update(product_template)
    product_template.products.each do |product|
      product.update(price: product_template.price)
    end
  end
end
