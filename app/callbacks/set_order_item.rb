class SetOrderItem
  def after_create(record)
    record.update(price: record.product.price,
                  product_name: record.product.name,
                  product_description: record.product.description,
                  product_author: record.product.author.name) if record.product
  end
end