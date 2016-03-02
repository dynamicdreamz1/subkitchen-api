class UnlikeProduct
  def call
    unlike
  end

  private

  attr_accessor :product, :current_user

  def initialize(product, current_user)
    @product = product
    @current_user = current_user
  end

  def unlike
    like = product.likes.find_by(user_id: current_user.id)
    if like
      LikesCounter.new.perform(like.id, -1)
      like.destroy
    else
      false
    end
  end
end