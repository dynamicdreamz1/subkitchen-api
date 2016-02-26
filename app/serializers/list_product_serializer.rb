class ListProductSerializer
  def as_json(options={})
    data = { id: product.id,
             author: product.author.name,
             price: product.product_template.price.to_s,
             name: product.name,
             product_image: product.image_url,
             likes: product.likes }

    data[:errors] = product.errors if product.errors.any?

    data.as_json(options)
  end

  private

  attr_reader :product

  def initialize(product)
    @product = product
  end
end