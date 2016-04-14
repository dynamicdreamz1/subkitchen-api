class SetOrderItem
  def after_create(record)
    record.update_columns(price: record.product.price) if record.product
  end
end
