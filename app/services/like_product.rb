class LikeProduct
  def call
    like
  end

  private

  attr_accessor :product, :current_user

  def initialize(product, current_user)
    @product = product
    @current_user = current_user
  end

  def like
    like = product.likes.create(user_id: current_user.id)
    if product.valid?
      LikesCounter.perform_async(like.id, 1)
    else
      false
    end
  end
end
