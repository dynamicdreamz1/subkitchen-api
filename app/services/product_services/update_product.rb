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
      product.published = params.published unless params.published.nil?
      product.description = params.description if params.description
      product.name = params.name if params.name
      update_tags(product) if params.tags
      product
  end

  def update_tags(product)
    product.tag_list.clear
    product.tag_list.add(params.tags)
  end
end
