class LikeProduct
  def call
    like
  end

  private

  attr_accessor :product, :current_user, :uuid

  def initialize(product, current_user, uuid = nil)
    @product = product
    @current_user = current_user
    @uuid = uuid
  end

  def like
    like = product.likes.create(user_id: current_user.try(:id), uuid: uuid)
    if product.valid?
      LikesCounter.perform_async(product.author_id, 1)
      like.reload
    else
      false
    end
  end
end
