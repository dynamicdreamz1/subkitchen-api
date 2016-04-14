describe WishList::Api, type: :request do

  describe '/api/v1/wish_list' do

    context 'add product to wish list' do

      before(:each) do
        @user = create(:user)
        @product = create(:product)
        post '/api/v1/wish_list', { product_id: @product.id }, auth_header_for(@user)
      end

      it 'should create product wishes' do
        expect(ProductWish.count).to eq(1)
      end

      it 'should add products to wish list' do
        expect(@user.wished_products.count).to eq(1)
      end

      it 'should return status success' do
        expect(response).to have_http_status(:success)
      end
    end

    context 'remove product from wish list' do

      before(:each) do
        @user = create(:user)
        @product = create(:product)
        create(:product_wish, user: @user, wished_product: @product)
        delete '/api/v1/wish_list', { product_id: @product.id }, auth_header_for(@user)
      end

      it 'should remove product from wish list' do
        expect(@user.wished_products.count).to eq(0)
      end

      it 'should return status success' do
        expect(response).to have_http_status(:success)
      end
    end

    context 'get wish list' do

      before(:each) do
        @user = create(:user)
        2.times{ create(:product_wish, user: @user, wished_product: create(:product)) }
        get '/api/v1/wish_list', {}, auth_header_for(@user)
      end

      it 'should return status success' do
        expect(response).to have_http_status(:success)
      end

      it 'should return wish list' do
        serialized_products = ProductListSerializer.new(@user.wished_products.page(1)).as_json
        expect(json['wish_list']).to eq(serialized_products)
      end
    end
  end
end
