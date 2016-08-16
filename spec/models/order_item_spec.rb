RSpec.describe OrderItem, type: :model do
  let(:user) { create(:user) }
  let(:artist) { create(:user, :artist) }
  let(:order) { create(:order) }
  let(:product) { create(:product, author: user) }
  let(:order_item) { create(:order_item, product: product, order: order) }

  describe 'SetOrderItem on create callback' do
    it 'should set price' do
      expect(order_item.price).to eq(product.price)
    end

    it 'should set style' do
      expect(order_item.style).to eq(product.product_template.style)
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

  describe 'last sales scope' do
    it 'should sort order items by latest sales' do
      p1 = create(:product, author: artist)
      p2 = create(:product, author: artist)
      p3 = create(:product, author: artist)
      create(:purchased_order_with_items, product: p3, purchased_at: DateTime.now - 1)
      create(:purchased_order_with_items, product: p2, purchased_at: DateTime.now - 2)
      create(:purchased_order_with_items, product: p1, purchased_at: DateTime.now - 3)

      expect(OrderItem.last_sales(artist).pluck(:product_id)).to eq([p3.id, p2.id, p1.id])
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
