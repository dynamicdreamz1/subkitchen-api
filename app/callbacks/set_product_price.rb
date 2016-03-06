class SetProductPrice
  def after_create(product)
    product.update_column(:price, product.product_template.price) if product.product_template
  end
end