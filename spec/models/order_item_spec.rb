RSpec.describe OrderItem, type: :model do
  let(:user) { create(:user) }
  let(:order) { create(:order) }
  let(:product) { create(:product, author: user) }
  let(:order_item) { create(:order_item, product: product, order: order) }

  describe 'SetOrderItem on create callback' do
    it 'should set price' do
      expect(order_item.price).to eq(product.price)
    end
  end

  describe 'OrderItemValidator' do
    it 'should not create when payment exist' do
      create(:payment, payable: order)
      order.reload

      expect do
        OrderItem.create!(order: order)
      end.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  it 'should have attributes' do
    item = OrderItem.create
    expect(item.errors[:order_id].present?).to eq(true)
    expect(item.errors[:product_id].present?).to eq(true)
    expect(item.errors[:template_variant_id].present?).to eq(true)
    expect(item.errors[:size].present?).to eq(true)
  end
end
