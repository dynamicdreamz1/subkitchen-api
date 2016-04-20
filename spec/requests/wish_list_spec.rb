describe WishList::Api, type: :request do

  describe '/api/v1/wish_list' do

    context 'add product to wish list' do

      before(:each) do
        @user = create(:user)
        @product = create(:product, :published)
        post '/api/v1/wish_list', { product_id: @product.id }, auth_header_for(@user)
      end

      it 'should create product wishes' do
        expect(ProductWish.count).to eq(1)
        expect(@user.wished_products.count).to eq(1)
        expect(response).to have_http_status(:success)
      end

      context 'does not add unpublished product to wish list' do

        before(:each) do
          @product = create(:product)
          post '/api/v1/wish_list', { product_id: @product.id }, auth_header_for(@user)
        end

        it 'should not add unpublished product' do
          expect(response).to have_http_status(:not_found)
          expect(@user.wished_products.count).to eq(1)
        end
      end

      context 'remove product from wish list' do

        before(:each) do
          @product = create(:product)
          create(:product_wish, user: @user, wished_product: @product)
          delete '/api/v1/wish_list', { product_id: @product.id }, auth_header_for(@user)
        end

        it 'should remove product from wish list' do
          expect(@user.wished_products.count).to eq(1)
          expect(response).to have_http_status(:success)
        end
      end
    end

    context 'get wish list' do

      before(:each) do
        @user = create(:user)
        2.times{ create(:product_wish, user: @user, wished_product: create(:product)) }
        get '/api/v1/wish_list', {}, auth_header_for(@user)
      end

      it 'should return wish list' do
        expect(response).to have_http_status(:success)
        serialized_products = ProductListSerializer.new(@user.wished_products.page(1)).as_json
        expect(response.body).to eq(serialized_products.to_json)
      end
    end
  end
end
