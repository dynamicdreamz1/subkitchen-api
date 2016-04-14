describe Products::Api, type: :request do
  let(:user) { create(:user, artist: false) }

  describe '/api/v1/products/:id' do
    describe 'delete product' do
      context 'when user is authenticated' do
        before(:each) do
          @product = create(:product, author: user)
          delete "/api/v1/products/#{@product.id}", {}, auth_header_for(user)
        end

        it 'should remove product' do
          expect(Product.count).to eq(0)
        end

        it 'should return status success' do
          expect(response).to have_http_status(:success)
        end

        it 'should match response schema' do
          expect(response).to match_response_schema('single_product')
        end

        it 'should return removed product' do
          serialized_product = ProductSerializer.new(@product.reload).as_json
          expect(response.body).to eq(serialized_product.to_json)
        end

        context 'and is not a product author' do
          before(:each) do
            @product = create(:product, author: create(:user))
            delete "/api/v1/products/#{@product.id}", {}, auth_header_for(user)
            @product.reload
          end

          it 'should return error' do
            expect(json['errors']).to eq('base' => ['unauthorized'])
          end

          it 'should return status unauthorized' do
            expect(response).to have_http_status(:unauthorized)
          end

          it 'should not delete product' do
            expect(@product.is_deleted).to eq(false)
          end
        end
      end

      context 'unauthenticated user' do
        before(:each) do
          @product = create(:product)
          delete "/api/v1/products/#{@product.id}", uuid: @product.uuid
        end

        it 'should remove product' do
          expect(Product.count).to eq(0)
        end

        it 'should return status success' do
          expect(response).to have_http_status(:success)
        end

        it 'should match response schema' do
          expect(response).to match_response_schema('single_product')
        end

        it 'should return removed product' do
          serialized_product = ProductSerializer.new(@product.reload).as_json
          expect(response.body).to eq(serialized_product.to_json)
        end

        context 'and is not a product author' do
          before(:each) do
            @product = create(:product)
            delete "/api/v1/products/#{@product.id}", uuid: '123'
            @product.reload
          end

          it 'should return error' do
            expect(json['errors']).to eq('base' => ['record not found'])
          end

          it 'should return status not_found' do
            expect(response).to have_http_status(:not_found)
          end

          it 'should not delete product' do
            expect(@product.is_deleted).to eq(false)
          end
        end
      end
    end
  end
end
