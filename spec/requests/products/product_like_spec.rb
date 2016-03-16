describe Products::Api, type: :request do
  let(:product_template){ create(:product_template) }
  let(:artist){ create(:user, artist: true, status: 'verified') }
  let(:user){ create(:user, artist: false) }
  let(:other_artist){ create(:user, artist: true, status: 'verified')}
  let(:product){ create(:product, author: other_artist, published: true) }
  let(:artist_product){ create(:product, author: artist, published: true) }

  describe '/api/v1/products' do
    describe 'LIKE product' do
      it 'should like product' do
        post "/api/v1/products/#{product.id}/toggle_like", {}, auth_header_for(artist)

        expect(response).to have_http_status(:success)
        product.reload
        expect(json['likes_count']).to eq(1)
      end

      it 'should not like own product' do
        post "/api/v1/products/#{artist_product.id}/toggle_like", {}, auth_header_for(artist)

        expect(response).to have_http_status(:unprocessable_entity)
        artist_product.reload
        expect(artist_product.likes.count).to eq(0)
        expect(json['errors']).to eq({'base'=>['cannot like own product']})
      end

      it 'should not create like' do
        artist.delete
        post "/api/v1/products/#{artist_product.id}/toggle_like", {}, auth_header_for(artist)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json['errors']).to eq({'base'=>['please try again later']})
      end
    end

    describe 'UNLIKE product' do
      it 'should unlike product' do
        create(:like, likeable_id: product.id, likeable_type: product.class.name, user: artist)
        expect(product.likes.count).to eq(1)

        post "/api/v1/products/#{product.id}/toggle_like", {}, auth_header_for(artist)

        expect(response).to have_http_status(:success)
        expect(json['likes_count']).to eq(0)
        expect(product.likes.count).to eq(0)
      end
    end
  end
end
