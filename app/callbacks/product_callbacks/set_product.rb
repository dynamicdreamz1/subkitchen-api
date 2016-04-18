class SetProduct
  def after_create(product)
    product.update_columns(price: product.template_variant.product_template.price) if product.template_variant.product_template
  end
end
