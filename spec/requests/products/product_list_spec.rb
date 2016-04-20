describe Products::Api, type: :request do
  let(:product_template) { create(:product_template) }
  let(:artist) { create(:user, artist: true) }
  let(:user) { create(:user, artist: false) }

  describe '/api/v1/products' do
    describe 'list of products' do
      context 'without page params' do
        before(:each) do
          2.times { create(:product) }
          get '/api/v1/products'
        end

        it 'should return first page of products' do
          serialized_products = ProductListSerializer.new(Product.sorted_by('created_at_desc').page(1)).as_json
          expect(response.body).to eq(serialized_products.to_json)
          expect(response).to have_http_status(:success)
          expect(response).to match_response_schema('products')
        end
      end

      context 'with page params' do
        before(:each) do
          create(:product)
          create(:product)
          @params = { page: 2, per_page: 1 }
          get '/api/v1/products', @params
          @products = Product.sorted_by('created_at_desc').page(@params[:page]).per(@params[:per_page])
        end

        it 'should return page of products' do
          expect(response).to match_response_schema('products')
          expect(response).to have_http_status(:success)
          serialized_products = ProductListSerializer.new(@products).as_json
          expect(response.body).to eq(serialized_products.to_json)
        end
      end
    end
  end
end
