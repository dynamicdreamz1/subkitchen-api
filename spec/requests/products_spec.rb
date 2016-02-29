describe Products::Api, type: :request do
  let(:image){ fixture_file_upload(Rails.root.join('app/assets/images/sizechart-hoodie.jpg'), 'image/jpg') }
  let(:product_template){ create(:product_template) }
  let(:artist){ create(:user, artist: true) }
  let(:user){ create(:user, artist: false) }

  before(:all) do
    create(:config, name: 'tax', value: '6.0')
    create(:config, name: 'shipping_cost', value: '7.0')
    create(:config, name: 'shipping_info', value: 'info')
    User.destroy_all
    Product.destroy_all
  end

  describe '/api/v1/products' do
    describe 'INDEX products' do
      it 'should return first page of products' do
        create(:product)

        get '/api/v1/products'

        serialized_products = ProductListSerializer.new(Product.page(1)).as_json
        expect(response).to have_http_status(:success)
        expect(response.body).to eq(serialized_products.to_json)
        expect(response).to match_response_schema('products')
      end

      it 'should paginate' do
        create(:product)
        create(:product)

        get '/api/v1/products?page=1&per_page=1'

        serialized_products = ProductListSerializer.new(Product.page(1).per(1)).as_json
        expect(response).to match_response_schema('products')
        expect(response.body).to eq(serialized_products.to_json)

        get '/api/v1/products?page=2&per_page=1'

        serialized_products = ProductListSerializer.new(Product.page(2).per(1)).as_json
        expect(response).to match_response_schema('products')
        expect(response.body).to eq(serialized_products.to_json)
      end
    end

    describe 'SHOW product' do
      it 'should return product' do
        product = create(:product, author: user)

        get "/api/v1/products/#{product.id}"

        serialized_product = ProductSerializer.new(product).as_json
        expect(response.body).to eq(serialized_product.to_json)
        expect(response).to match_response_schema('single_product')
      end
    end

    describe 'CREATE product' do
      context 'artist true' do
        it 'should create and publish product' do
          post '/api/v1/products', { name: 'new_product',
                                     product_template_id: product_template.id,
                                     description: 'description',
                                     image: image,
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
                                     published: false}

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
                                     published: true}

          product = Product.first
          expect(product).to be_nil
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response).to match_response_schema('single_product')
        end
      end
    end

    describe 'DELETE product' do
      context 'authorized user' do
        it 'should remove product' do
          product = create(:product, user_id: user.id)

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

  describe '/api/v1/products/publish' do
    describe 'PUBLISH product' do
      context 'artist true' do
        it 'should publish product' do
          product = create(:product, user_id: artist.id)

          post '/api/v1/products/publish', { product_id: product.id }, auth_header_for(artist)

          serialized_product = ProductSerializer.new(product.reload).as_json
          expect(response.body).to eq(serialized_product.to_json)
          expect(product.published).to be_truthy
          expect(response).to match_response_schema('single_product')
        end

        it 'should not publish when artist is not an author' do
          other_artist = create(:user, artist: true)
          product = create(:product, user_id: other_artist.id)

          post '/api/v1/products/publish', { product_id: product.id }, auth_header_for(artist)

          expect(response).to have_http_status(:unprocessable_entity)
          expect(json['errors']).to eq({'base'=>['no product with given id or user is not an author']})
        end
      end

      context 'artist false' do
        it 'should not publish product' do
          product = create(:product, user_id: user.id)

          post '/api/v1/products/publish', { product_id: product.id }, auth_header_for(user)

          expect(product.published).to be_falsey
          expect(response).to match_response_schema('single_product')
        end
      end
    end

    describe 'LIKE product' do
      it 'should like product' do
        product = create(:product, user_id: artist.id, published: true)

        post '/api/v1/products/like', { product_id: product.id }

        product.reload
        expect(product.likes).to eq(1)
      end

      it 'should not like own product' do
        product = create(:product, user_id: artist.id, published: true)

        post '/api/v1/products/like', { product_id: product.id }, auth_header_for(artist)

        product.reload
        expect(product.likes).to eq(0)
        expect(json['errors']).to eq({'base'=>['cannot like own product']})
      end
    end
  end
end
