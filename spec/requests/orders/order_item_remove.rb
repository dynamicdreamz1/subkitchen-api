describe Products::Api, type: :request do
  let(:user) { create(:user) }
  let(:product) { create(:product) }

  before(:all) do
    create(:config, name: 'tax', value: '6.0')
    create(:config, name: 'shipping_cost', value: '7.0')
    create(:config, name: 'shipping_info', value: 'info')
  end

  describe 'DELETE ITEM' do
    describe 'authorized user' do
      it 'should remove item from order' do
        order = create(:order, user: user)
        item = create(:order_item, order: order, product: product, size: 's')

        delete "/api/v1/orders/item/#{item.id}", { uuid: order.uuid }, auth_header_for(user)

        item = OrderItem.find_by(order: order, product: product)
        expect(item).to be_nil
        expect(response).to match_response_schema('order')
      end
    end

    describe 'unauthorized user' do
      it 'should remove item from order' do
        order = create(:order, user: user)
        item = create(:order_item, order: order, product: product)

        delete "/api/v1/orders/item/#{item.id}", { uuid: order.uuid }

        item = OrderItem.find_by(order: order, product: product)
        expect(item).to be_nil
        expect(response).to match_response_schema('order')
      end
    end

    it 'updates total/subtotal after deleting item from order' do
      order = create(:order, user: user, shipping_cost: 7.0, tax: 6.0, subtotal_cost: 10, total_cost: 17.6, tax_cost: 0.6)
      item = create(:order_item, order: order, product: product, price: 10)

      delete "/api/v1/orders/item/#{item.id}", { uuid: order.uuid }

      order.reload
      expect(order.subtotal_cost).to eq(0)
      expect(order.total_cost).to eq(0)
      expect(order.tax_cost).to eq(0)
      expect(order.shipping_cost).to eq(7.0)
      expect(order.tax).to eq(6.0)
    end
  end
end
