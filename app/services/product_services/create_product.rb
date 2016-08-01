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
    User.transaction do
      product = Product.new(name: @params.name,
                            product_template_id: @params.product_template_id,
                            description: @params.description,
                            uploaded_image: @params.uploaded_image,
                            preview: preview,
                            published: @params.published,
                            published_at: (@params.published ? DateTime.now : nil))
      product.tag_list.add(@params.tags)
      product.author_id = @user.id if @user
      product.save!
      PublishedCounter.perform_async(product.id, 1) if @params.published
      product
    end
  end

  def preview
    ActionDispatch::Http::UploadedFile.new(@params.preview)
  end
end
