describe Products::Api, type: :request do
  let(:image){ fixture_file_upload(Rails.root.join('app/assets/images/sizechart-hoodie.jpg'), 'image/jpg') }
  let(:product_template){ create(:product_template) }
  let(:artist){ create(:user, status: 'verified', artist: true) }
  let(:user){ create(:user, artist: false) }

  describe '/api/v1/products' do


    describe 'CREATE product' do
      context 'artist true' do
        it 'should create and publish product' do
          post '/api/v1/products', { name: 'new_product',
                                     product_template_id: product_template.id,
                                     description: 'description',
                                     image: image,
                                     tags: ['cats'],
                                     published: true}, auth_header_for(artist)

          product = Product.first
          serialized_product = ProductSerializer.new(product).as_json
          expect(product.image_id).to be_truthy
          expect(response.body).to eq(serialized_product.to_json)
          expect(response).to match_response_schema('single_product')
        end
      end

      context 'artist false' do
        it 'should create product' do
          post '/api/v1/products', { name: 'new_product',
                                     product_template_id: product_template.id,
                                     description: 'description',
                                     image: image,
                                     tags: ['cats'],
                                     published: false}, auth_header_for(user)

          product = Product.first
          serialized_product = ProductSerializer.new(product).as_json
          expect(product.image_id).to be_truthy
          expect(response.body).to eq(serialized_product.to_json)
          expect(response).to match_response_schema('single_product')
        end

        it 'should not create and publish product' do
          post '/api/v1/products', { name: 'new_product',
                                     product_template_id: product_template.id,
                                     description: 'description',
                                     image: image,
                                     tags: ['cats'],
                                     published: true}, auth_header_for(user)

          product = Product.first
          expect(product).to be_nil
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response).to match_response_schema('single_product')
        end
      end

      context 'unauthorized user' do
        it 'should create product' do
          post '/api/v1/products', { name: 'new_product',
                                     product_template_id: product_template.id,
                                     description: 'description',
                                     image: image,
                                     tags: ['cats'],
                                     published: false}

          product = Product.first
          expect(response).to have_http_status(:success)
          serialized_product = ProductSerializer.new(product).as_json
          expect(product.image_id).to be_truthy
          expect(response.body).to eq(serialized_product.to_json)
          expect(response).to match_response_schema('single_product')
        end

        it 'should not create and publish product' do
          post '/api/v1/products', { name: 'new_product',
                                     product_template_id: product_template.id,
                                     description: 'description',
                                     image: image,
                                     tags: ['cats'],
                                     published: true}

          product = Product.first
          expect(product).to be_nil
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response).to match_response_schema('single_product')
        end
      end
    end
  end
end
