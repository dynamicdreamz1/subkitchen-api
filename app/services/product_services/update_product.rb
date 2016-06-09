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
    unless params.published.nil?
      update_counter(product)
      product.published = params.published
    end
    product.description = params.description if params.description
    product.name = params.name if params.name
    update_tags(product) if params.tags
    product
  end

  def update_tags(product)
    product.tag_list.clear
    product.tag_list.add(params.tags)
  end

  def update_counter(product)
    published = if product.published && !params.published
                  -1
                elsif !product.published && params.published
                  1
                else
                  0
                end
    PublishedCounter.perform_async(product.id, published)
  end
end
