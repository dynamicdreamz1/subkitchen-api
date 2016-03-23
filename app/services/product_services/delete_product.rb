class DeleteProduct
  def call
    delete
  end

  private

  def initialize(product)
    @product = product
  end

  def delete
    PublishedCounter.new.perform(@product.id, -1)
    @product.update_attribute(:is_deleted, true)
  end
end