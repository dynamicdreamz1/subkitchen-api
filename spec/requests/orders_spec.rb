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
          post '/api/v1/orders/item', { product_id: product.id, size: 's' }, auth_header_for(user)
        end.to change(Order, :count).by(1)
        expect(Order.last.user).to eq(user)
        expect(response).to match_response_schema('order')
      end

      it 'should add item to order' do
        post '/api/v1/orders/item', { product_id: product.id, size: 's' }, auth_header_for(user)

        order = Order.find_by(user_id: user.id, state: :active)
        expect(order).not_to be_nil
        expect(order.order_items.size).to eq(1)
        expect(response).to match_response_schema('order')
      end

      it 'should increment quantity' do
        order = create(:order, user: user)
        create(:order_item, product: product, order: order, size: 'm')

        post '/api/v1/orders/item', { product_id: product.id, size: 'm' }, auth_header_for(user)

        order = Order.find_by(user_id: user.id, state: :active)
        expect(order.order_items.first.quantity).to eq(2)
        expect(response).to match_response_schema('order')
      end

      it 'should not increment quantity when size different' do
        order = create(:order, user: user)
        create(:order_item, product: product, order: order, size: 'm')

        post '/api/v1/orders/item', { product_id: product.id, size: 's' }, auth_header_for(user)

        order = Order.find_by(user_id: user.id, state: :active)
        expect(order.order_items.first.quantity).to eq(1)
        expect(order.order_items.size).to eq(2)
        expect(response).to match_response_schema('order')
      end
    end

    context 'unauthorized user' do
      it 'should create order with no user' do
        expect do
          post '/api/v1/orders/item', { product_id: product.id, size: 's' }
        end.to change(Order, :count).by(1)
        expect(Order.last.user).to be_nil
        expect(response).to match_response_schema('order')
      end

      it 'should add item to order' do
        order = create(:order)

        post '/api/v1/orders/item', { product_id: product.id, size: 'm', uuid: order.uuid }

        order = Order.find_by(uuid: order.uuid)
        expect(order).not_to be_nil
        expect(order.order_items.size).to eq(1)
        expect(response).to match_response_schema('order')
      end

      it 'should increment quantity' do
        order = create(:order, user: user)
        create(:order_item, product: product, order: order, size: 'l')

        post '/api/v1/orders/item', { product_id: product.id, size: 'l', uuid: order.uuid }

        order = Order.find_by(uuid: order.uuid)
        expect(order.order_items.first.quantity).to eq(2)
        expect(response).to match_response_schema('order')
      end
    end

    it 'updates total/subtotal after adding item to order' do
      order = create(:order, user: user)
      product_template = create(:product_template, price: 10)
      product = create(:product, product_template: product_template)


      post '/api/v1/orders/item', { product_id: product.id, size: 'm', uuid: order.uuid }

      order.reload
      expect(order.subtotal_cost).to eq(10)
      expect(order.total_cost).to eq(17.6)
      expect(order.tax_cost).to eq(0.6)
      expect(order.shipping_cost).to eq(7.0)
      expect(order.tax).to eq(6.0)
    end
  end

  describe 'DELETE ITEM' do
    describe 'authorized user' do
      it 'should remove item from order' do
        order = create(:order, user: user)
        item = create(:order_item, order: order, product: product, size: 's')

        delete '/api/v1/orders/item', { order_item_id: item.id }, auth_header_for(user)

        item = OrderItem.find_by(order: order, product: product)
        expect(item).to be_nil
        expect(response).to match_response_schema('order')
      end

      it 'should decrement' do
        order = create(:order, user: user)
        create(:order_item, order: order, product: product)
        item = create(:order_item, order: order, product: product)

        delete '/api/v1/orders/item', { order_item_id: item.id }, auth_header_for(user)

        item = OrderItem.find_by(order: order, product: product)
        expect(item.quantity).to eq(1)
        expect(response).to match_response_schema('order')
      end
    end

    describe 'unauthorized user' do
      it 'should remove item from order' do
        order = create(:order, user: user)
        item = create(:order_item, order: order, product: product)

        delete '/api/v1/orders/item', { order_item_id: item.id }

        item = OrderItem.find_by(order: order, product: product)
        expect(item).to be_nil
        expect(response).to match_response_schema('order')
      end

      it 'should decrement' do
        order = create(:order, user: user)
        create(:order_item, order: order, product: product)
        item = create(:order_item, order: order, product: product)

        delete '/api/v1/orders/item', { order_item_id: item.id }

        item = OrderItem.find_by(order: order, product: product)
        expect(item.quantity).to eq(1)
        expect(response).to match_response_schema('order')
      end
    end

    it 'updates total/subtotal after deleting item from order' do
      order = create(:order, user: user, shipping_cost: 7.0, tax: 6.0, subtotal_cost: 10, total_cost: 17.6, tax_cost: 0.6)
      item = create(:order_item, order: order, product: product, price: 10)

      delete '/api/v1/orders/item', { order_item_id: item.id }

      order.reload
      expect(order.subtotal_cost).to eq(0)
      expect(order.total_cost).to eq(0)
      expect(order.tax_cost).to eq(0)
      expect(order.shipping_cost).to eq(7.0)
      expect(order.tax).to eq(6.0)
    end
  end

  describe 'PAYPAL' do
    it 'should return payment link to paypal' do
      order = create(:order, user: user)
      product = create(:product)
      create(:order_item, order: order, product: product)

      get '/api/v1/orders/paypal_payment_url', { return_path: '', uuid: order.uuid }

      payment = Payment.find_by(payable_id: order.id, payable_type: order.class.name)
      expect(json['url']).to eq(PaypalPayment.new(payment, '').call)
      expect(response).to match_response_schema('paypal')
    end

    it 'should check if product exists' do
      order = create(:order, user: user)
      product = create(:product)
      create(:order_item, order: order, product: product)
      DeleteResource.new(product).call

      get '/api/v1/orders/paypal_payment_url', { return_path: '', uuid: order.uuid }

      expect(json['errors']).to eq({'base'=>['some of the items had to be removed because the products does not exist anymore']})
    end
  end

  describe 'CHECKOUT' do
    it 'should checkout' do
      order = create(:order, user: nil)
      product = create(:product)
      create(:order_item, order: order, product: product)
      create(:order_item, order: order, product: product)
      params = { uuid: order.uuid }

      get '/api/v1/orders/checkout', params

      expect(response).to match_response_schema('checkout')
    end

    it 'should update items before checkout' do
      order = create(:order, user: nil)
      product = create(:product)
      create(:order_item, order: order, product: product)
      params = { uuid: order.uuid }
      DeleteResource.new(product).call

      get '/api/v1/orders/checkout', params

      expect(response).to match_response_schema('checkout')
    end
  end
end
