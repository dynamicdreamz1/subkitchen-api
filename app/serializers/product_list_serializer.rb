class ProductListSerializer
  include ApplicationHelper

  def as_json(options={})
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
        author: (product.author ? product.author.name : nil),
        price: number_to_price(product.product_template.price),
        size: product.product_template.size,
        description: product.description,
        name: product.name,
        likes_count: product.likes_count,
        product_image: product.image_url,
        shipping: Config.shipping_info,
        shipping_cost: Config.shipping_cost,
        tax: Config.tax,
        size_chart: product.product_template.size_chart_url
    }
  end
end
