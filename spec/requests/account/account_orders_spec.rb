describe AccountsOrders::Api, type: :request do
  let(:user){ create(:user) }

  before do
    create(:config, name: 'tax', value: '6.00')
    create(:config, name: 'shipping_cost', value: '7.00')
  end

  describe '/api/v1/account/orders' do
    it 'should return status success' do
      get '/api/v1/account/orders', {}, auth_header_for(user)

      expect(response).to have_http_status(:success)
    end

    it 'should match json schema' do
      order = create(:order, user: user)
      create(:order_item, order: order, product: create(:product))

      get '/api/v1/account/orders', {}, auth_header_for(user)

      expect(response).to match_response_schema('account_orders')
    end

    it 'should return orders of user' do
      create(:order, user: user)

      get '/api/v1/account/orders', {}, auth_header_for(user)

      serialized_orders = OrderListSerializer.new(user.orders.page(1).per(5)).as_json
      expect(response.body).to eq(serialized_orders.to_json)
    end

    it 'should paginate orders of user' do
      create(:order, user: user)
      create(:order, user: user)

      get '/api/v1/account/orders', {per_page: 1, page: 1}, auth_header_for(user)

      user_orders = user.orders.page(1).per(1)
      serialized_orders = OrderListSerializer.new(user_orders).as_json
      expect(response.body).to eq(serialized_orders.to_json)
      expect(user_orders.total_pages).to eq(2)
    end
  end

  describe '/api/v1/account/orders/:uuid' do
    it 'should return status success' do
      order = create(:order, user: user)

      get "/api/v1/account/orders/#{order.uuid}", {}, auth_header_for(user)

      expect(response).to have_http_status(:success)
    end

    it 'should match json schema' do
      order = create(:order, user: user)
      create(:order_item, order: order, product: create(:product))

      get "/api/v1/account/orders/#{order.uuid}", {}, auth_header_for(user)

      expect(response).to match_response_schema('checkout')
    end

    it 'should match serialized order' do
      order = create(:order, user: user)
      create(:order_item, order: order, product: create(:product))

      get "/api/v1/account/orders/#{order.uuid}", {}, auth_header_for(user)

      serialized_order = CheckoutSerializer.new(order).as_json
      expect(response.body).to eq(serialized_order.to_json)
    end
  end
end
