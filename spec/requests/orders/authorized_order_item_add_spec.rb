describe Products::Api, type: :request do
  let(:user) { create(:user) }
  let(:product) { create(:product) }

  describe '/api/v1/orders/item' do

    before(:each) do
      post '/api/v1/orders/item', { product_id: product.id, size: 's', quantity: 1 }, auth_header_for(user)
      @order = Order.last
      @item = @order.order_items.first
    end

    it 'should create order' do
      expect(Order.count).to eq(1)
    end

    it 'should associate user to order' do
      expect(@order.user).to eq(user)
    end

    it 'should match json response schema' do
      expect(response).to match_response_schema('order')
    end

    it 'should return status success' do
      expect(response).to have_http_status(:success)
    end

    it 'should add item to order' do
      expect(@order.order_items.size).to eq(1)
    end

    it 'should set profit' do
      expect(@item.profit).to eq(product.product_template.profit)
    end

    context 'after payment is completed' do

      before(:each) do
        create(:payment, payable: @order, payment_status: 'completed')
        post '/api/v1/orders/item', { product_id: create(:product).id, size: 's', quantity: 1 }, auth_header_for(user)
      end

      it 'should return status unprocessable_entity when trying to add new item' do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'should return error when trying to add new item' do
        expect(json['errors']).to eq({'base'=>['cannot change already paid order']})
      end

      it 'should not create order item' do
        expect(OrderItem.count).to eq(1)
      end
    end

    context 'adding duplicate items' do

      before(:each) do
        post '/api/v1/orders/item', { product_id: product.id, size: 's', quantity: 5 }, auth_header_for(user)
        @item.reload
      end

      it 'should increment quantity' do
        expect(@item.quantity).to eq(6)
      end

      it 'should match response schema' do
        expect(response).to match_response_schema('order')
      end

      it 'should return status success' do
        expect(response).to have_http_status(:success)
      end
    end

    context 'adding different items' do

      before(:each) do
        post '/api/v1/orders/item', { product_id: product.id, size: 'm', quantity: 1 }, auth_header_for(user)
      end

      it 'should not increment quantity' do
        expect(@item.quantity).to eq(1)
      end

      it 'should create another order item' do
        expect(@order.order_items.size).to eq(2)
      end

      it 'should match response schema' do
        expect(response).to match_response_schema('order')
      end

      it 'should return status success' do
        expect(response).to have_http_status(:success)
      end
    end

    context 'update costs' do

      before(:each) do
        @order = create(:order, user: user)
        product_template = create(:product_template, price: 10)
        product = create(:product, product_template: product_template)
        params = { product_id: product.id, size: 'm', quantity: 1, uuid: @order.uuid }
        post '/api/v1/orders/item', params, auth_header_for(user)
        @order.reload
      end

      it 'should update costs after adding item to order' do
        expect(@order.subtotal_cost).to eq(10)
        expect(@order.total_cost).to eq(17.6)
        expect(@order.tax_cost).to eq(0.6)
        expect(@order.shipping_cost).to eq(7.00)
        expect(@order.tax).to eq(6)
      end

      it 'should return status success' do
        expect(response).to have_http_status(:success)
      end
    end
  end
end
