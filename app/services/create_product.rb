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
    Product.new(name: @params.name,
                user_id: @user.id,
                product_template_id: @params.product_template_id,
                description: @params.description,
                image: image(@params.image),
                published: @params.published
    )
  end

  def image(image)
    ActionDispatch::Http::UploadedFile.new(image)
  end
end