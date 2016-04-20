describe Products::Api, type: :request do
  let(:user) { create(:user) }
  let(:product) { create(:product) }

  describe '/api/v1/orders/item/:id' do
    context 'authorized user' do
      before(:each) do
        order = create(:order, user: user)
        item = create(:order_item, order: order, product: product, size: 's')

        delete "/api/v1/orders/item/#{item.id}", { uuid: order.uuid }, auth_header_for(user)

        @item = OrderItem.find_by(order: order, product: product)
      end

      it 'should remove item from order' do
        expect(@item).to be_nil
        expect(response).to match_response_schema('order')
        expect(response).to have_http_status(:success)
      end
    end

    describe 'unauthorized user' do
      before(:each) do
        @order = create(:order, user: user)
        item = create(:order_item, order: @order, product: product)

        delete "/api/v1/orders/item/#{item.id}", uuid: @order.uuid

        @item = OrderItem.find_by(order: @order, product: product)
        @order.reload
      end

      it 'should remove item from order' do
        expect(@item).to be_nil
        expect(response).to match_response_schema('order')
        expect(response).to have_http_status(:success)
      end
    end

    context 'after delete' do
      before(:each) do
        @order = create(:order, user: user, shipping_cost: 7.00, tax: 6, subtotal_cost: 10, total_cost: 17.6, tax_cost: 0.6)
        item = create(:order_item, order: @order, product: product, price: 10)

        delete "/api/v1/orders/item/#{item.id}", uuid: @order.uuid

        @order.reload
      end

      it 'should update costs' do
        expect(@order.subtotal_cost).to eq(0)
        expect(@order.total_cost).to eq(0)
        expect(@order.tax_cost).to eq(0)
        expect(@order.shipping_cost).to eq(7.00)
        expect(@order.tax).to eq(6)
      end
    end
  end
end
