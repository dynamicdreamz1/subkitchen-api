class DeleteProduct
  def call
    update_counter
    delete
  end

  private

  attr_accessor :product

  def initialize(product)
    @product = product
  end

  def update_counter
    PublishedCounter.new.perform(product.id, -1) if product.published
  end

  def delete
    product.update_attribute(:is_deleted, true)
  end
end
