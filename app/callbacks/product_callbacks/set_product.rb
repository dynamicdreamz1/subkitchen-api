class SetProduct
  def after_create(product)
    product.update_columns(price: product.product_template.price) if product.product_template
  end
end