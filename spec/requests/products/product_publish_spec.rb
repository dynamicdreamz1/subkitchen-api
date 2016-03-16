describe Products::Api, type: :request do
  let(:product_template){ create(:product_template) }
  let(:artist){ create(:user, status: 'verified', artist: true) }
  let(:user){ create(:user, artist: false) }

  describe '/api/v1/products/publish' do
    describe 'PUBLISH product' do
      context 'artist true' do
        it 'should publish product' do
          product = create(:product, author: artist)

          post '/api/v1/products/publish', { product_id: product.id }, auth_header_for(artist)

          serialized_product = ProductSerializer.new(product.reload).as_json
          expect(response.body).to eq(serialized_product.to_json)
          expect(product.published).to be_truthy
          expect(response).to match_response_schema('single_product')
        end

        it 'should not publish when artist is not an author' do
          other_artist = create(:user, artist: true)
          product = create(:product, author: other_artist)

          post '/api/v1/products/publish', { product_id: product.id }, auth_header_for(artist)

          expect(response).to have_http_status(:unprocessable_entity)
          expect(json['errors']).to eq({'base'=>['cannot publish not own product']})
        end
      end

      context 'artist false' do
        it 'should not publish product' do
          product = create(:product, author: user)

          post '/api/v1/products/publish', { product_id: product.id }, auth_header_for(user)

          expect(product.published).to be_falsey
          expect(response).to match_response_schema('single_product')
        end
      end
    end
  end
end
