class UpdateProductPrices
  def after_update(record)
    record.products.each do |product|
      product.update(price: self.price)
    end
  end
end