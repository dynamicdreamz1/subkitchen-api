class ProductListSerializer
  def as_json(options={})
    serialized_products = products.map do |product|
      single_product = {
        id: product.id,
        author: (product.author ? product.author.name : nil),
        price: product.product_template.price.to_s,
        size: product.product_template.size,
        description: product.description,
        name: product.name,
        likes: product.likes,
        product_image: product.image_url,
        shipping: Config.shipping_info,
        shipping_cost: Config.shipping_cost,
        tax: Config.tax,
        size_chart: product.product_template.size_chart_url
      }
      single_product[:errors] = product.errors if product.errors.any?
      single_product
    end

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
end
