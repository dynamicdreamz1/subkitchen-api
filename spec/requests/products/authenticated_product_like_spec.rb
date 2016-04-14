describe Products::Api, type: :request do
  let(:artist){ create(:user, artist: true, status: 'verified') }
  let(:user){ create(:user, artist: false) }
  let(:product){ create(:product, author: create(:user, artist: true, status: 'verified'), published: true) }
  let(:artist_product){ create(:product, author: artist, published: true) }

  describe '/api/v1/products/:id/toggle_like' do

    context 'when user is authenticated' do
      context 'when product is not liked' do

        before(:each) do
          post "/api/v1/products/#{product.id}/toggle_like", {}, auth_header_for(artist)
          product.reload
        end

        it 'should like product' do
          like = Like.where(likeable: product, user: artist)
          expect(like.exists?).to eq(true)
        end

        it 'should return status success' do
          expect(response).to have_http_status(:success)
        end

        it 'should return likes count' do
          expect(json['likes_count']).to eq(1)
        end

        context 'and current user is product author' do

          before(:each) do
            post "/api/v1/products/#{artist_product.id}/toggle_like", {}, auth_header_for(artist)
            artist_product.reload
          end

          it 'should not like own product' do
            expect(artist_product.likes.count).to eq(0)
          end

          it 'should return error' do
            expect(json['errors']).to eq({'base'=>['cannot like own product']})
          end

          it 'should return status unprocessable_entity' do
            expect(response).to have_http_status(:unprocessable_entity)
          end
        end
      end

      context 'when product is liked' do

        before(:each) do
          create(:like, likeable_id: product.id, likeable_type: product.class.name, user: artist)
          expect(product.likes.count).to eq(1)
          post "/api/v1/products/#{product.id}/toggle_like", {}, auth_header_for(artist)
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
