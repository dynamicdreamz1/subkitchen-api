describe AccountsDesigns::Api, type: :request do
  let(:user){ create(:user) }

  describe '/api/v1/account/designs' do

    context 'no params' do
      before(:each) do
        create(:product, author: user)
        get '/api/v1/account/designs', {}, auth_header_for(user)
      end

      it 'should return status success' do
        expect(response).to have_http_status(:success)
      end

      it 'should match json schema' do
        expect(response).to match_response_schema('account_designs')
      end

      it 'should return orders of user' do
        serialized_orders = UserDesignsSerializer.new(user.products.page(1).per(5)).as_json
        expect(response.body).to eq(serialized_orders.to_json)
      end
    end

    context 'with pagination params' do
      before(:each) do
        2.times{ create(:product, author: user) }

        get '/api/v1/account/designs', {per_page: 1, page: 1}, auth_header_for(user)
        @user_products = user.products.page(1).per(1)
      end

      it 'should paginate orders of user' do
        serialized_products = UserDesignsSerializer.new(@user_products).as_json
        expect(response.body).to eq(serialized_products.to_json)
      end

      it 'should has pages' do
        expect(@user_products.total_pages).to eq(2)
      end
    end
  end
end
