describe Products::Api, type: :request do
  let(:product_template){ create(:product_template) }
  let(:artist){ create(:user, artist: true) }
  let(:user){ create(:user, artist: false) }

  describe '/api/v1/products' do
    describe 'SHOW product' do
      it 'should return product' do
        product = create(:product, author: user)

        get "/api/v1/products/#{product.id}"

        serialized_product = ProductSerializer.new(product).as_json
        expect(response.body).to eq(serialized_product.to_json)
        expect(response).to match_response_schema('single_product')
      end
    end
  end
end
