class PublishProduct
  def call
    publish
  end

  private

  attr_accessor :product, :current_user

  def initialize(product, current_user)
    @product = product
    @current_user = current_user
  end

  def publish
    return false unless is_author?
    product.update(published: true, published_at: DateTime.now)
    PublishedCounter.perform_async(product.id, 1)
  end

  def is_author?
    product.author == current_user
  end
end