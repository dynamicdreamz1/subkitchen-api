class UserDesignsSerializer
  def as_json(options = {})
    data = {
      products: serialized_products,
      meta: {
        current_page: products.current_page,
        total_pages: products.total_pages
      }
    }

    data.as_json(options)
  end

  private

  attr_accessor :products

  def initialize(products)
    @products = products
  end

  def serialized_products
    products.map do |product|
      single_product = single_product(product)

      single_product[:errors] = product.errors if product.errors.any?
      single_product
    end
  end

  def single_product(product)
    {
      id: product.id,
      name: product.name,
      product_image: product.image_url,
      published: product.published,
      tags: product.tag_list
    }
  end
end
