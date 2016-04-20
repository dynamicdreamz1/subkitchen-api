class UpdateProduct
  def call
    update_product
  end

  private

  attr_reader :params, :user

  def initialize(params, user = nil)
    @params = params
    @user = user
  end

  def update_product
      product = Product.find(params.id)
      product.published = params.published if params.published
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
