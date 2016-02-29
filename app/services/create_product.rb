class CreateProduct
  def call
    create_product
  end

  private

  def initialize(user, params)
    @params = params
    @user = user
  end

  def create_product
    product = Product.new(name: @params.name,
                product_template_id: @params.product_template_id,
                description: @params.description,
                image: image(@params.image),
                published: @params.published
    )
    product.user_id = @user.id if @user
    product
  end

  def image(image)
    ActionDispatch::Http::UploadedFile.new(image)
  end
end