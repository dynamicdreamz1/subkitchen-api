describe Products::Api, type: :request do
  let(:product_template){ create(:product_template) }
  let(:artist){ create(:user, artist: true) }
  let(:user){ create(:user, artist: false) }

  describe '/api/v1/products' do
    describe 'LIKE product' do
      it 'should like product' do
        other_artist = create(:user, artist: true)
        product = create(:product, author: other_artist, published: true)

        post '/api/v1/products/like', { product_id: product.id }, auth_header_for(artist)

        product.reload
        expect(product.likes.count).to eq(1)
      end

      it 'should not like own product' do
        product = create(:product, author: artist, published: true)

        post '/api/v1/products/like', { product_id: product.id }, auth_header_for(artist)

        product.reload
        expect(product.likes.count).to eq(0)
        expect(json['errors']).to eq({'base'=>['cannot like own product']})
      end

      it 'should not like product twice' do
        other_artist = create(:user, artist: true)
        product = create(:product, author: other_artist, published: true)
        create(:like, likeable_id: product.id, likeable_type: product.class.name, user: artist)

        post '/api/v1/products/like', { product_id: product.id }, auth_header_for(artist)

        product.reload
        expect(product.likes.count).to eq(1)
        expect(json['errors']).to eq({'base'=>['cannot like product more than once']})
      end
    end
  end
end
