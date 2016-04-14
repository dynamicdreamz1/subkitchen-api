class UnlikeProduct
  def call
    unlike
  end

  private

  attr_accessor :product, :current_user, :uuid

  def initialize(product, current_user, uuid=nil)
    @product = product
    @current_user = current_user
    @uuid = uuid
  end

  def unlike
    like = nil
    like = product.likes.find_by!(user_id: current_user.id) if current_user
    like ||= product.likes.find_by!(uuid: uuid)
    if like
      LikesCounter.new.perform(product.author_id, -1)
      like.destroy && like
    else
      false
    end
  end
end
