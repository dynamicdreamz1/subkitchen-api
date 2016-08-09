class UpdateProduct
  def call
    update_product
  end

  private

  attr_reader :params, :user, :id

  def initialize(id, params, user = nil)
    @id = id
    @params = params
    @user = user
  end

  def update_product
    product = Product.find(id)
		published = product.published
		product.tap do |product|
			product.published = params.published
			product.published_at = (params.published ? DateTime.now : nil)
			product.description = params.description if params.description
			product.name = params.name if params.name
			update_tags(product) if params.tags
			product.save
			update_counter(published, params.published, product.id)
		end
  end

  def update_tags(product)
    product.tag_list.clear
    product.tag_list.add(params.tags)
	end

	def update_counter(published, new_published, product_id)
		count = if published && !new_published
			-1
		elsif !published && new_published
			1
		end
		PublishedCounter.perform_async(product_id, count)
	end
end
