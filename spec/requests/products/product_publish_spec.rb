describe Products::Api, type: :request do
  let(:product_template) { create(:product_template) }
  let(:artist) { create(:user, status: 'verified', artist: true) }
  let(:user) { create(:user, artist: false) }

  describe '/api/v1/products/publish' do
    context 'when user is an artist' do
      before(:each) do
        @product = create(:product, author: artist)
        post '/api/v1/products/publish', { product_id: @product.id }, auth_header_for(artist)
        @product.reload
      end

      it 'should return status success' do
        expect(response).to have_http_status(:success)
      end

      it 'should return published product' do
        serialized_product = ProductSerializer.new(@product.reload).as_json
        expect(response.body).to eq(serialized_product.to_json)
      end

      it 'should match response schema' do
        expect(response).to match_response_schema('single_product')
      end

      it 'should publish product' do
        expect(@product.published).to be_truthy
      end

      context 'and is not an author' do
        before(:each) do
          other_artist = create(:user, artist: true)
          @product = create(:product, author: other_artist)

          post '/api/v1/products/publish', { product_id: @product.id }, auth_header_for(artist)
        end

        it 'should not publish when artist is not an author' do
          expect(@product.published).to eq(false)
        end

        it 'should return status unprocessable_entity' do
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'should return error' do
          expect(json['errors']).to eq('base' => ['cannot publish not own product'])
        end
      end
    end

    context 'when user is not an artist' do
      before(:each) do
        @product = create(:product, author: user)
        post '/api/v1/products/publish', { product_id: @product.id }, auth_header_for(user)
      end

      it 'should not publish product' do
        expect(@product.published).to be_falsey
      end

      it 'should return status unprocessable_entity' do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'should return error' do
        expect(json['errors']).to eq('base' => ["Validation failed: Published can't be true when you're not an artist"])
      end
    end
  end
end
