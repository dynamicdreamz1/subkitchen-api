RSpec.describe OrderItem, type: :model do
  before(:each) do
    user = create(:user)
    @order = create(:order)
    @product = create(:product, author: user)
    @order_item = create(:order_item, product: @product, order: @order)
  end

  describe 'SetOrderItem on create callback' do
    it 'should set price' do
      expect(@order_item.price).to eq(@product.price)
    end
  end

  describe 'OrderItemValidator' do
    it 'should not create when payment exist' do
      create(:payment, payable: @order)
      @order.reload

      expect do
        OrderItem.create!(order: @order)
      end.to raise_error(ActiveRecord::RecordInvalid)
    end
  end
end
