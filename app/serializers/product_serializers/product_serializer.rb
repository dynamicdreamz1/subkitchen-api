class ProductSerializer
  include ApplicationHelper

  def as_json(options = {})
    data = {
      product: {
        id: product.id,
        is_deleted: product.is_deleted,
        author_id: (product.author ? product.author.id : nil),
        price: product.price,
        sizes: product.product_template.size,
        product_template_id: product.product_template.id,
        description: product.description,
        name: product.name,
        product_type: product.product_template.product_type,
        tags: product.tag_list.sort,
        likes_count: product.likes_count,
        promoters: product.likes.order('created_at DESC').pluck(:user_id).uniq.compact,
        comments: product.comments.order('created_at DESC').pluck(:id).uniq.compact,
        comments_count: product.comments.count,
        image_url: image,
        preview_url: product_image(:preview, 1024, 1024),
        big_preview_url: product_image(:preview, 2048, 2048),
        shipping: Config.shipping_info,
        shipping_cost: Config.shipping_cost,
        tax: Config.tax,
        size_chart: Figaro.env.app_host + Refile.attachment_url(product.product_template, :size_chart),
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

	def image
		product.image ? product_image(:image, 2048, 2048) : product.uploaded_image
	end

  def product_image(img_key, h, w)
    Figaro.env.app_host.to_s + Refile.attachment_url(product, img_key, :fill, h, w, format: :png)
  end

  def variants
    product.product_template.template_variants.map { |v| { id: v.id, color: v.color.color_value } }
  end
end
