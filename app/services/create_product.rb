class CreateProduct
  def call
    create_product
  end

  private

  def initialize(params, user = nil)
    @params = params
    @user = user
  end

  def create_product
    product = Product.new(name: @params.name,
                product_template_id: @params.product_template_id,
                description: @params.description,
                image: image,
                published: @params.published,
                published_at: (@params.published ? DateTime.now : nil)
    )
    product.user_id = @user.id if @user
    product
  end

  def image
    ActionDispatch::Http::UploadedFile.new(@params.image)
  end
end
