class SetPublishedAt
  def after_save(product)
    product.update_column(:published_at, DateTime.now)
  end
end