RSpec.describe OrderItem, type: :model do
  before do
    create(:config, name: 'tax', value: '6.0')
    create(:config, name: 'shipping_cost', value: '7.0')
    create(:config, name: 'shipping_info', value: 'info')
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