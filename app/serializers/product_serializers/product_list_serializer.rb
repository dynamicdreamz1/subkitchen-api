class ProductListSerializer
  include ApplicationHelper

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
      author: (product.author ? product.author.name : nil),
      price: product.product_template.price,
      sizes: product.product_template.size,
      name: product.name,
      likes_count: product.likes_count,
      product_image: product_image(product),
      variants: variants(product)
    }
  end


  def product_image(product)
    img_key = product.preview ? :preview : :image
    Figaro.env.app_host.to_s + Refile.attachment_url(product, img_key, :fill, 400, 400, format: :png)
  end

  def variants(product)
    product.product_template.template_variants.map{|v| {id: v.id, color: v.color.color_value}}
  end
end
