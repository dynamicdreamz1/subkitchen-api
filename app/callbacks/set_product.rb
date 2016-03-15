class SetProduct
  def after_create(product)
    product.update_columns(price: product.product_template.price, template_type: product.product_template.product_type) if product.product_template
  end
end