describe Products::Api, type: :request do
  let(:artist) { create(:user, artist: true, status: :verified) }

  describe '/api/v1/products/:id' do
    describe 'update product' do
      before(:each) do
        @product = create(:product, author: artist)
        @params = { id: @product.id,
                    product: {
                      published: true,
                      tags: ['Space'],
                      description: 'New Description',
                      name: 'NewName'
                    } }
        put "/api/v1/products/#{@product.id}", @params, auth_header_for(artist)
        @product.reload
      end

      it 'should return product' do
        expect(response).to have_http_status(:success)
        serialized_product = ProductSerializer.new(@product).as_json
        expect(response.body).to eq(serialized_product.to_json)
        expect(response).to match_response_schema('single_product')
      end

      it 'should update product' do
        expect(@product.published).to eq(@params[:product][:published])
        expect(@product.description).to eq(@params[:product][:description])
        expect(@product.name).to eq(@params[:product][:name])
        expect(@product.tag_list).to eq(@params[:product][:tags])
      end
    end
  end
end
