class SetOrderItem
  def after_create(record)
    record.update_columns(price: record.product.price,
                          style: record.product.product_template.style,
                          profit: record.product.product_template.profit)
  end
end
