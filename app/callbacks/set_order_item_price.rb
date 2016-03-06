class SetOrderItemPrice
  def after_create(record)
    record.update(price: record.product.price) if record.product
  end
end