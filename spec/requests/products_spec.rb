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

        get '/api/v1/products', { page: 1, per_page: 1 }

        serialized_products = ProductListSerializer.new(Product.sorted_by('created_at_desc').page(1).per(1)).as_json
        expect(response).to match_response_schema('products')
        expect(response.body).to eq(serialized_products.to_json)

        get '/api/v1/products', { page: 2, per_page: 1 }

        serialized_products = ProductListSerializer.new(Product.sorted_by('created_at_desc').page(2).per(1)).as_json
        expect(response).to match_response_schema('products')
        expect(response.body).to eq(serialized_products.to_json)
      end

      context 'sort' do

        before do
          create(:product, name: 'AAA', created_at: 1.week.ago, product_template: create(:product_template, price: 100))
          create(:product, name: 'BBB', created_at: 2.weeks.ago, product_template: create(:product_template, price: 200))
          create(:product, name: 'CCC', created_at: 3.weeks.ago, product_template: create(:product_template, price: 300))
        end

        it 'should sort by created_at param desc' do
          get '/api/v1/products', {sorted_by: 'created_at_desc'}

          sorted_products = Product.sorted_by('created_at_desc').page(1).per(3)
          serialized_products = ProductListSerializer.new(sorted_products).as_json
          expect(response.body).to eq(serialized_products.to_json)
        end

        it 'should sort by created_at param asc' do
          get '/api/v1/products', {sorted_by: 'created_at_asc'}

          sorted_products = Product.sorted_by('created_at_asc').page(1).per(3)
          serialized_products = ProductListSerializer.new(sorted_products).as_json
          expect(response.body).to eq(serialized_products.to_json)
        end

        it 'should sort by name param desc' do
          get '/api/v1/products', {sorted_by: 'name_desc'}

          sorted_products = Product.sorted_by('name_desc').page(1).per(3)
          serialized_products = ProductListSerializer.new(sorted_products).as_json
          expect(response.body).to eq(serialized_products.to_json)
        end

        it 'should sort by name param asc' do
          get '/api/v1/products', {sorted_by: 'name_asc'}

          sorted_products = Product.sorted_by('name_asc').page(1).per(3)
          serialized_products = ProductListSerializer.new(sorted_products).as_json
          expect(response.body).to eq(serialized_products.to_json)
        end

        it 'should sort by price param desc' do
          get '/api/v1/products', {sorted_by: 'price_desc'}

          sorted_products = Product.sorted_by('price_desc').page(1).per(3)
          serialized_products = ProductListSerializer.new(sorted_products).as_json
          expect(response.body).to eq(serialized_products.to_json)
        end

        it 'should sort by price param asc' do
          get '/api/v1/products', {sorted_by: 'price_asc'}

          sorted_products = Product.sorted_by('price_asc').page(1).per(3)
          serialized_products = ProductListSerializer.new(sorted_products).as_json
          expect(response.body).to eq(serialized_products.to_json)
        end

        it 'should sort by best sellers param' do
          get '/api/v1/products', {sorted_by: 'best_sellers'}

          sorted_products = Product.sorted_by('best_sellers').page(1).per(3)
          serialized_products = ProductListSerializer.new(sorted_products).as_json
          expect(response.body).to eq(serialized_products.to_json)
        end
      end

      context 'filter' do

        before do
          @p1 = create(:product, name: 'AAA', created_at: 1.week.ago, product_template: create(:product_template, price: 100, product_type: 'tee'))
          @p2 = create(:product, name: 'BBB', created_at: 2.weeks.ago, product_template: create(:product_template, price: 200, product_type: 'hoodie'))
          @p3 = create(:product, name: 'CCC', created_at: 3.weeks.ago, product_template: create(:product_template, price: 300, product_type: 'yoga_pants'))
          @p1.tag_list.add(['cats', 'space'])
          @p1.save
          @p3.tag_list.add(['music'])
          @p3.save
        end

        it 'should filter products with product type' do
          get '/api/v1/products', {with_product_type: ['tee']}

          products = Product.sorted_by('created_at_desc').where(id: @p1.id)
          products = products.page(1).per(3)
          serialized_products = ProductListSerializer.new(products).as_json
          expect(response.body).to eq(serialized_products.to_json)
        end

        it 'should filter products with multiple product types' do
          get '/api/v1/products', {with_product_type: ['tee','hoodie','yoga_pants']}

          products = Product.sorted_by('created_at_desc').where(id: [@p1.id, @p2.id, @p3.id])
          products = products.page(1).per(3)
          serialized_products = ProductListSerializer.new(products).as_json
          expect(response.body).to eq(serialized_products.to_json)
        end

        it 'should filter products with price range' do
          get '/api/v1/products', {with_price_range: [0, 101]}

          products = Product.sorted_by('created_at_desc').where(id: [@p1.id])
          products = products.page(1).per(3)
          serialized_products = ProductListSerializer.new(products).as_json
          expect(response.body).to eq(serialized_products.to_json)
        end

        it 'should filter products with tags' do
          get '/api/v1/products', {with_tags: ['cats', 'music']}

          products = Product.sorted_by('created_at_desc').where(id: [@p1.id, @p3.id])
          products = products.page(1).per(3)
          serialized_products = ProductListSerializer.new(products).as_json
          expect(response.body).to eq(serialized_products.to_json)
        end
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
          expect(json['errors']).to eq({'base'=>['cannot publish not own product']})
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
        other_artist = create(:user, artist: true)
        product = create(:product, user_id: other_artist.id, published: true)

        post '/api/v1/products/like', { product_id: product.id }, auth_header_for(artist)

        product.reload
        expect(product.likes.count).to eq(1)
      end

      it 'should not like own product' do
        product = create(:product, user_id: artist.id, published: true)

        post '/api/v1/products/like', { product_id: product.id }, auth_header_for(artist)

        product.reload
        expect(product.likes.count).to eq(0)
        expect(json['errors']).to eq({'base'=>['cannot like own product']})
      end

      it 'should not like product twice' do
        other_artist = create(:user, artist: true)
        product = create(:product, user_id: other_artist.id, published: true)
        create(:like, likeable_id: product.id, likeable_type: product.class.name, user: artist)

        post '/api/v1/products/like', { product_id: product.id }, auth_header_for(artist)

        product.reload
        expect(product.likes.count).to eq(1)
        expect(json['errors']).to eq({'base'=>['cannot like product more than once']})
      end
    end
  end
end
