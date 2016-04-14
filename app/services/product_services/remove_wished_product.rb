class RemoveWishedProduct
  def call
    remove_product
  end

  private

  attr_reader :user, :product

  def initialize(user, product)
    @user = user
    @product = product
  end

  def remove_product
    product_wish = ProductWish.find_by!(user: user, wished_product: product)
    product_wish.delete
  end
end