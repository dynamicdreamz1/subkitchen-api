describe Products::Api, type: :request do
  let(:image) { fixture_file_upload(Rails.root.join('app/assets/images/1024x1024.png'), 'image/png') }
  let(:product_template) { create(:product_template) }
  let(:artist) { create(:user, status: 'verified', artist: true) }
  let(:user) { create(:user, artist: false) }

  describe '/api/v1/products' do
    describe 'CREATE product' do
      context 'when user is an artist' do
        before(:each) do
          @params = { name: 'new_product',
                      product_template_id: product_template.id,
                      description: 'description',
                      image: image,
                      tags: ['cats'],
                      published: true }
          post '/api/v1/products', @params, auth_header_for(artist)

          @product = Product.last
        end

        it 'should publish product' do
          expect(@product.published).to eq(true)
        end

        it 'should create product with correct data' do
          expect(@product.name).to eq(@params[:name])
          expect(@product.description).to eq(@params[:description])
          expect(@product.product_template_id).to eq(@params[:product_template_id])
          expect(@product.tag_list).to eq(@params[:tags])
        end

        it 'should upload image' do
          expect(@product.image_id).to be_truthy
        end

        it 'should match response schema' do
          expect(response).to match_response_schema('single_product')
        end

        it 'should return created product' do
          serialized_product = ProductSerializer.new(@product).as_json
          expect(response.body).to eq(serialized_product.to_json)
        end

        it 'should return status success' do
          expect(response).to have_http_status(:success)
        end
      end

      context 'when user is not an artist' do
        before(:each) do
          @params = { name: 'new_product',
                      product_template_id: product_template.id,
                      description: 'description',
                      image: image,
                      tags: ['cats'],
                      published: false }
          post '/api/v1/products', @params, auth_header_for(user)

          @product = Product.last
        end

        it 'should create product with correct data' do
          expect(@product.name).to eq(@params[:name])
          expect(@product.description).to eq(@params[:description])
          expect(@product.product_template_id).to eq(@params[:product_template_id])
          expect(@product.tag_list).to eq(@params[:tags])
        end

        it 'should not publish product' do
          expect(@product.published).to eq(false)
        end

        it 'should match response schema' do
          expect(response).to match_response_schema('single_product')
        end

        it 'should return product' do
          serialized_product = ProductSerializer.new(@product).as_json
          expect(response.body).to eq(serialized_product.to_json)
        end

        it 'should upload image' do
          expect(@product.image_id).to be_truthy
        end

        context 'and try to publish product' do
          before(:each) do
            post '/api/v1/products', { name: 'new_product',
                                       product_template_id: product_template.id,
                                       description: 'description',
                                       image: image,
                                       tags: ['cats'],
                                       published: true }, auth_header_for(user)

            @product = Product.first
          end

          it 'should return error' do
            expect(json['errors']).to eq('published' => ["can't be true when you're not an artist"])
          end

          it 'should return status unprocessable_entity' do
            expect(response).to have_http_status(:unprocessable_entity)
          end
        end
      end
    end
  end
end