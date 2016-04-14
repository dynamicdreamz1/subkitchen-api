describe Products::Api, type: :request do
  let(:product) { create(:product, author: create(:user, artist: true, status: 'verified'), published: true) }

  describe '/api/v1/products/:id/toggle_like' do
    context 'when user is not authenticated' do
      context 'when product is not liked' do
        before(:each) do
          post "/api/v1/products/#{product.id}/toggle_like"
          product.reload
        end

        it 'should like product' do
          expect(product.likes.count).to eq(1)
        end

        it 'should return status success' do
          expect(response).to have_http_status(:success)
        end

        it 'should return likes count' do
          expect(json['likes_count']).to eq(1)
        end
      end

      context 'when product is liked' do
        before(:each) do
          like = create(:like, likeable: product)
          post "/api/v1/products/#{product.id}/toggle_like", uuid: like.uuid
        end

        it 'should unlike product' do
          expect(product.likes.count).to eq(0)
        end

        it 'should return status success' do
          expect(response).to have_http_status(:success)
        end

        it 'should return likes count' do
          expect(json['likes_count']).to eq(0)
        end
      end
    end
  end
end
