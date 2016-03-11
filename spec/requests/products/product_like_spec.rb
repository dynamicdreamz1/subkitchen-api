describe Products::Api, type: :request do
  let(:product_template){ create(:product_template) }
  let(:artist){ create(:user, artist: true) }
  let(:user){ create(:user, artist: false) }
  let(:other_artist){ create(:user, artist: true)}
  let(:product){ create(:product, author: other_artist, published: true) }
  let(:artist_product){ create(:product, author: artist, published: true) }

  describe '/api/v1/products' do
    describe 'LIKE product' do
      it 'should like product' do
        post "/api/v1/products/#{product.id}/likes", {}, auth_header_for(artist)

        product.reload
        expect(json['likes']).to eq(1)
      end

      it 'should not like own product' do
        post "/api/v1/products/#{artist_product.id}/likes", {}, auth_header_for(artist)

        product.reload
        expect(product.likes_count).to eq(0)
        expect(json['errors']).to eq({'base'=>['cannot like own product']})
      end

      it 'should not like product twice' do
        create(:like, likeable_id: product.id, likeable_type: product.class.name, user: artist)

        post "/api/v1/products/#{product.id}/likes", {}, auth_header_for(artist)

        product.reload
        expect(product.likes_count).to eq(1)
        expect(json['errors']).to eq({'base'=>['cannot like product more than once']})
      end
    end

    describe 'UNLIKE product' do
      it 'should unlike product' do
        create(:like, likeable_id: product.id, likeable_type: product.class.name, user: artist)

        delete "/api/v1/products/#{product.id}/likes", {}, auth_header_for(artist)

        expect(json['likes']).to eq(0)
      end

      it 'should not unlike product when product not liked' do
        delete "/api/v1/products/#{product.id}/likes", {}, auth_header_for(artist)

        expect(json['errors']).to eq({'base'=>['no like with given user id']})
      end
    end
  end
end
