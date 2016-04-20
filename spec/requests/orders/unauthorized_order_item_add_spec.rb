describe Products::Api, type: :request do
  let(:user) { create(:user) }
  let(:product) { create(:product) }
  let(:variant) { create(:template_variant) }

  describe '/api/v1/orders/item' do
    before(:each) do
      params = { product_id: product.id, size: 's', quantity: 1, template_variant_id: variant.id }
      post '/api/v1/orders/item', params
      @order = Order.last
      @item = @order.order_items.first
    end

    it 'should create order' do
      expect(Order.count).to eq(1)
      expect(@order.user).to eq(nil)
      expect(response).to match_response_schema('order')
      expect(response).to have_http_status(:success)
    end

    it 'should add item to order' do
      expect(@order.order_items.size).to eq(1)
      expect(@item.profit).to eq(product.product_template.profit)
    end

    context 'after payment is completed' do
      before(:each) do
        create(:payment, payable: @order, payment_status: 'completed')
        params = { product_id: create(:product).id, size: 's', quantity: 1, uuid: @order.uuid, template_variant_id: variant.id }
        post '/api/v1/orders/item', params
      end

      it 'should not create order item' do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json['errors']).to eq('base' => ['cannot change already paid order'])
        expect(OrderItem.count).to eq(1)
      end
    end

    context 'adding duplicate items' do
      before(:each) do
        params = { product_id: product.id, size: 's', quantity: 5, uuid: @order.uuid, template_variant_id: variant.id }
        post '/api/v1/orders/item', params
        @item.reload
      end

      it 'should increment quantity' do
        expect(response).to have_http_status(:success)
        expect(@item.quantity).to eq(6)
        expect(response).to match_response_schema('order')
      end
    end

    context 'adding different items' do
      before(:each) do
        params = { product_id: product.id, size: 'm', quantity: 1, uuid: @order.uuid, template_variant_id: variant.id }
        post '/api/v1/orders/item', params
      end

      it 'should not increment quantity' do
        expect(@item.quantity).to eq(1)
      end

      it 'should create another order item' do
        expect(response).to have_http_status(:success)
        expect(@order.order_items.size).to eq(2)
        expect(response).to match_response_schema('order')
      end
    end

    context 'update costs' do
      before(:each) do
        @order = create(:order, user: user)
        product_template = create(:product_template, price: 10)
        product = create(:product, product_template: product_template)
        params = { product_id: product.id, size: 'm', quantity: 1, uuid: @order.uuid, template_variant_id: variant.id }
        post '/api/v1/orders/item', params
        @order.reload
      end

      it 'should update costs after adding item to order' do
        expect(response).to have_http_status(:success)

        expect(@order.subtotal_cost).to eq(10)
        expect(@order.total_cost).to eq(17.6)
        expect(@order.tax_cost).to eq(0.6)
        expect(@order.shipping_cost).to eq(7.00)
        expect(@order.tax).to eq(6)
      end
    end
  end
end
