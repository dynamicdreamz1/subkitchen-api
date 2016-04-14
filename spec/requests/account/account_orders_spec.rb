describe AccountsOrders::Api, type: :request do
  let(:user) { create(:user) }

  describe '/api/v1/account/orders' do
    context 'with no params' do
      before(:each) do
        order = create(:order, user: user)
        create(:order_item, order: order, product: create(:product))
        get '/api/v1/account/orders', {}, auth_header_for(user)
      end

      it 'should return status success' do
        expect(response).to have_http_status(:success)
      end

      it 'should match json schema' do
        expect(response).to match_response_schema('account_orders')
      end

      it 'should return orders of user' do
        serialized_orders = OrderListSerializer.new(user.orders.page(1).per(5)).as_json
        expect(response.body).to eq(serialized_orders.to_json)
      end
    end

    context 'with pagination params' do
      before(:each) do
        2.times { create(:order, user: user) }
        get '/api/v1/account/orders', { per_page: 1, page: 1 }, auth_header_for(user)
        @user_orders = user.orders.page(1).per(1)
      end

      it 'should paginate orders of user' do
        serialized_orders = OrderListSerializer.new(@user_orders).as_json
        expect(response.body).to eq(serialized_orders.to_json)
      end

      it 'should has pages' do
        expect(@user_orders.total_pages).to eq(2)
      end

      it 'should return status success' do
        expect(response).to have_http_status(:success)
      end
    end
  end
end
