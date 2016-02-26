class ProductProfileSerializer
  def as_json(options={})
    data = { product:
                 { id: product.id,
                   name: product.name,
                   product_image: product.image_url,
                   published: product.published }}

    data[:errors] = product.errors if product.errors.any?

    data.as_json(options)
  end

  private

  attr_reader :product

  def initialize(product)
    @product = product
  end
end
