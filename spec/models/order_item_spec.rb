RSpec.describe OrderItem, type: :model do
  before do
    user = create(:user)
    @product = create(:product, author: user)
    @order_item = create(:order_item, product: @product )
  end

  it 'sets price' do
    price = @product.price
    @product.price = 100
    @product.save
    expect(@order_item.price).to eq(price)
  end
end