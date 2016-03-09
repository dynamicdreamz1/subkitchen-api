describe Products::Api, type: :request do
  let(:product_template){ create(:product_template) }
  let(:artist){ create(:user, artist: true) }
  let(:user){ create(:user, artist: false) }

  describe '/api/v1/products' do
    describe 'DELETE product' do
      context 'authorized user' do
        it 'should remove product' do
          product = create(:product, author: user)

          expect do
            delete "/api/v1/products/#{product.id}", {}, auth_header_for(user)
          end.to change(Product, :count).by(-1)

          serialized_product = ProductSerializer.new(product.reload).as_json
          expect(response.body).to eq(serialized_product.to_json)
          expect(response).to match_response_schema('single_product')
        end
      end

      context 'unauthorized user' do
        it 'should remove product' do
          product = create(:product)

          expect do
            delete "/api/v1/products/#{product.id}", {}
          end.to change(Product, :count).by(-1)

          serialized_product = ProductSerializer.new(product.reload).as_json
          expect(response.body).to eq(serialized_product.to_json)
          expect(response).to match_response_schema('single_product')
        end
      end
    end
  end
end