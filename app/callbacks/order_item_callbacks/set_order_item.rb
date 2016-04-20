class SetOrderItem
  def after_create(record)
    record.update_columns(price: record.product.price,
                          profit: record.product.product_template.profit)
  end
end
