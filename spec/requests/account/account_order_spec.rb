describe AccountsOrders::Api, type: :request do
  let(:user){ create(:user) }

  describe '/api/v1/account/orders/:uuid' do

    before(:each) do
      @order = create(:order, user: user)
      create(:order_item, order: @order, product: create(:product))
      get "/api/v1/account/orders/#{@order.uuid}", {}, auth_header_for(user)
    end

    it 'should return status success' do
      expect(response).to have_http_status(:success)
    end

    it 'should match json schema' do
      expect(response).to match_response_schema('checkout')
    end

    it 'should match serialized order' do
      serialized_order = CheckoutSerializer.new(@order).as_json
      expect(response.body).to eq(serialized_order.to_json)
    end
  end
end