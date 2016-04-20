describe Products::Api, type: :request do
  let(:user) { create(:user, artist: false) }

  describe '/api/v1/products/:id' do
    describe 'single product' do
      before(:each) do
        @product = create(:product, author: user)
        get "/api/v1/products/#{@product.id}"
      end

      it 'should return product' do
        serialized_product = ProductSerializer.new(@product).as_json
        expect(response.body).to eq(serialized_product.to_json)
        expect(response).to match_response_schema('single_product')
        expect(response).to have_http_status(:success)
      end
    end
  end
end
