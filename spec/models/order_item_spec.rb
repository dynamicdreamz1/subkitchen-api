RSpec.describe OrderItem, type: :model do
  before do
    create(:config, name: 'tax', value: '6')
    create(:config, name: 'shipping_cost', value: '7.00')
    create(:config, name: 'shipping_info', value: 'info')
    user = create(:user)
    @product = create(:product, author: user)
    @order_item = create(:order_item, product: @product )
  end

  describe 'SetOrderItem on create callback' do
    it 'should set price' do
      expect(@order_item.price).to eq(@product.price)
    end

    it 'should set product name' do
      expect(@order_item.product_name).to eq(@product.name)
    end

    it 'should set product description' do
      expect(@order_item.product_description).to eq(@product.description)
    end

    it 'should set product author' do
      expect(@order_item.product_author).to eq(@product.author.name)
    end
  end
end
