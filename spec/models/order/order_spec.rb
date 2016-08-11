RSpec.describe Order, type: :model do
  let(:order) { create(:order) }
  let(:no_design_product) { create(:product) }
  let(:design_product) { create(:product, design_id: '123') }

  describe 'scopes' do
    context 'completed scope' do
      it 'should return purchased orders' do
        purchased_order = create(:order, order_status: 4)
        expect(Order.fulfilled).to contain_exactly(purchased_order)
      end
    end

    context 'waiting_products scope' do
      it 'should return all products waiting for design' do
        create(:order_item, order: order, product: no_design_product)

        expect(Order.waiting_products(order)).to contain_exactly(no_design_product)
      end

      it 'should not return products with design' do
        create(:order_item, order: order, product: design_product)

        expect(Order.waiting_products(order)).to eq([])
      end
    end
  end

  describe 'SetTaxAndShipping on create callback' do
    it 'should set tax and shipping cost' do
      expect(order.shipping_cost).to eq(Config.shipping_cost.to_d)
      expect(order.tax).to eq(Config.tax.to_d)
    end
  end

  describe 'AddressValidator' do
    it 'should not update address when payment completed' do
      create(:payment, payable: order)

      expect do
        order.update!(address: 'abcd')
      end.to raise_error(ActiveRecord::RecordInvalid)
    end
  end
end
