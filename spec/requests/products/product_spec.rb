describe Products::Api, type: :request do
  let(:user) { create(:user, artist: true, status: :verified) }

  describe '/api/v1/products/:id' do
    describe 'single product' do
      it 'should return product' do
        product = create(:product, author: user, published: true)
        serialized_product = ProductSerializer.new(product).as_json

        get "/api/v1/products/#{product.id}"

        expect(response).to have_http_status(:success)
        expect(response.body).to eq(serialized_product.to_json)
        expect(response).to match_response_schema('single_product')
      end

      it 'should return 404 for private product' do
        product = create(:product, author: user)

        get "/api/v1/products/#{product.id}"

        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
