describe AccountsOrders::Api, type: :request do
  let(:user) { create(:user) }

  describe '/api/v1/orders' do
    context 'with no params' do
      before(:each) do
        order = create(:order, user: user)
        create(:order_item, order: order, product: create(:product))
        get '/api/v1/orders', {}, auth_header_for(user)
      end

      it 'should return orders of user' do
        serialized_orders = OrderListSerializer.new(user.orders.order('created_at DESC')).as_json
        expect(response.body).to eq(serialized_orders.to_json)
        expect(response).to match_response_schema('account_orders')
        expect(response).to have_http_status(:success)
      end
    end
  end
end
