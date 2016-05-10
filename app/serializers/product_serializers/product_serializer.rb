class ProductSerializer
  include ApplicationHelper

  def as_json(options = {})
    data = {
      product: {
        id: product.id,
        is_deleted: product.is_deleted,
        author: (product.author ? product.author.name : nil),
        author_id: (product.author ? product.author.id : nil),
        price: product.price,
        sizes: product.product_template.size,
        description: product.description,
        name: product.name,
        product_type: product.product_template.product_type,
        tags: product.tag_list,
        likes_count: product.likes_count,
        promoters: product.likes.order('created_at DESC').pluck(:user_id).uniq.compact,
        comments: product.comments.order('created_at DESC').pluck(:id).uniq.compact,
        comments_count: product.comments.count,
        product_image: product_image,
        shipping: Config.shipping_info,
        shipping_cost: Config.shipping_cost,
        tax: Config.tax,
        size_chart: product.product_template.size_chart_url,
        variants: variants
      }
    }
    data[:errors] = product.errors if product.errors.any?

    data.as_json(options)
  end

  private

  attr_accessor :product

  def initialize(product)
    @product = product
  end

  def product_image
    img_key = product.preview ? :preview : :image
    Figaro.env.app_host.to_s + Refile.attachment_url(product, img_key, :fill, 400, 400, format: :png)
  end

  def variants
    product.product_template.template_variants.map{|v| {id: v.id, color: v.color.color_value}}
  end
end
