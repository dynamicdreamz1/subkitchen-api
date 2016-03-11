describe Products::Api, type: :request do
  let(:user) { create(:user) }
  let(:product) { create(:product) }

  before(:all) do
    create(:config, name: 'tax', value: '6.0')
    create(:config, name: 'shipping_cost', value: '7.0')
    create(:config, name: 'shipping_info', value: 'info')
  end

  describe 'ADD ITEM' do
    context 'authorized user' do
      it 'should create order with user' do
        expect do
          post '/api/v1/orders/item', { product_id: product.id, size: 's', quantity: 1 }, auth_header_for(user)
        end.to change(Order, :count).by(1)
        expect(Order.last.user).to eq(user)
        expect(response).to match_response_schema('order')
      end

      it 'should add item to order' do
        post '/api/v1/orders/item', { product_id: product.id, size: 's', quantity: 1 }, auth_header_for(user)

        order = Order.find_by(user_id: user.id, active: true)
        expect(order).not_to be_nil
        expect(order.order_items.size).to eq(1)
        expect(response).to match_response_schema('order')
      end

      it 'should increment quantity' do
        order = create(:order, user: user)
        create(:order_item, product: product, order: order, size: 'm')

        post '/api/v1/orders/item', { product_id: product.id, size: 'm', quantity: 1 }, auth_header_for(user)

        order = Order.find_by(user_id: user.id, active: true)
        expect(order.order_items.first.quantity).to eq(2)
        expect(response).to match_response_schema('order')
      end

      it 'should not increment quantity when size different' do
        order = create(:order, user: user)
        create(:order_item, product: product, order: order, size: 'm')

        post '/api/v1/orders/item', { product_id: product.id, size: 's', quantity: 1 }, auth_header_for(user)

        order = Order.find_by(user_id: user.id, active: true)
        expect(order.order_items.first.quantity).to eq(1)
        expect(order.order_items.size).to eq(2)
        expect(response).to match_response_schema('order')
      end
    end

    context 'unauthorized user' do
      it 'should create order with no user' do
        expect do
          post '/api/v1/orders/item', { product_id: product.id, size: 's', quantity: 1 }
        end.to change(Order, :count).by(1)
        expect(Order.last.user).to be_nil
        expect(response).to match_response_schema('order')
      end

      it 'should add item to order' do
        order = create(:order)

        post '/api/v1/orders/item', { product_id: product.id, size: 'm', quantity: 1, uuid: order.uuid }

        order = Order.find_by(uuid: order.uuid)
        expect(order).not_to be_nil
        expect(order.order_items.size).to eq(1)
        expect(response).to match_response_schema('order')
      end

      it 'should increment quantity' do
        order = create(:order, user: user)
        create(:order_item, product: product, order: order, size: 'l')

        post '/api/v1/orders/item', { product_id: product.id, size: 'l', quantity: 1, uuid: order.uuid }

        order = Order.find_by(uuid: order.uuid)
        expect(order.order_items.first.quantity).to eq(2)
        expect(response).to match_response_schema('order')
      end

      it 'should set quantity' do
        order = create(:order, user: user)
        item = create(:order_item, product: product, order: order, size: 'l')

        put "/api/v1/orders/item/#{item.id}", { quantity: 0, uuid: order.uuid }

        order = Order.find_by(uuid: order.uuid)
        expect(order.order_items.first.quantity).to eq(0)
        expect(response).to match_response_schema('order')
      end
    end

    it 'updates total/subtotal after adding item to order' do
      order = create(:order, user: user)
      product_template = create(:product_template, price: 10)
      product = create(:product, product_template: product_template)


      post '/api/v1/orders/item', { product_id: product.id, size: 'm', quantity: 1, uuid: order.uuid }

      order.reload
      expect(order.subtotal_cost).to eq(10)
      expect(order.total_cost).to eq(17.6)
      expect(order.tax_cost).to eq(0.6)
      expect(order.shipping_cost).to eq(7.0)
      expect(order.tax).to eq(6.0)
    end
  end
end