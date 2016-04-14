class AddWishedProduct
  def call
    add_product
  end

  private

  attr_reader :user, :product

  def initialize(user, product)
    @user = user
    @product = product
  end

  def add_product
    ProductWish.create!(user: user, wished_product: product)
  end
end