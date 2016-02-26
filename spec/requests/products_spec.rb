describe Products::Api, type: :request do
  describe '/api/v1/products' do
    it 'returns first page of products' do
      create(:product)
      get '/api/v1/products'
      expect(response).to have_http_status(:success)
      expect(json["products"]).to eq(Product.page(1).map{|p| ProductSerializer.new(p).as_json.stringify_keys})
    end

    it 'paginates' do
      create(:product)
      create(:product)
      get '/api/v1/products?page=1&per_page=1'
      expect(json["products"]).to eq(Product.page(1).per(1).map{|p| ProductSerializer.new(p).as_json.stringify_keys})
      get '/api/v1/products?page=2&per_page=1'
      expect(json["products"]).to eq(Product.page(2).per(1).map{|p| ProductSerializer.new(p).as_json.stringify_keys})
    end

    it 'publishes product' do
      artist = create(:user, artist: true)
      product = create(:product, user_id: artist.id)
      post '/api/v1/products/publish', { product_id: product.id }
      product.reload
      expect(product.published).to be_truthy
    end

    it 'should not publish product' do
      user = create(:user, artist: false)
      product = create(:product, user_id: user.id)
      post '/api/v1/products/publish', { product_id: product.id }
      expect(product.published).to be_falsey
    end
  end

  describe '/api/v1/products/:id' do
    it 'returns product' do
      user = create(:user)
      product = create(:product, author: user)
      get "/api/v1/products/#{product.id}"
      expect(json["product"]).to eq(ProductSerializer.new(product).as_json.stringify_keys)
    end
  end

  describe '/api/v1/products' do
    it 'should create product' do
      image = fixture_file_upload(Rails.root.join("app/assets/images/sizechart-hoodie.jpg"), 'image/jpg')
      user = create(:user)
      product_template = create(:product_template)
      post '/api/v1/products', { name: 'new_product',
                                 product_template_id: product_template.id,
                                 description: 'description',
                                 image: image,
                                 published: false}, auth_header_for(user)
      product = Product.first
      expect(response.body).to eq(product.to_json)
      expect(product.image_id).to be_truthy
    end

    it 'should not publish product when artist false' do
      image = fixture_file_upload(Rails.root.join("app/assets/images/sizechart-hoodie.jpg"), 'image/jpg')
      user = create(:user)
      product_template = create(:product_template)
      post '/api/v1/products', { name: 'new_product',
                                 product_template_id: product_template.id,
                                 description: 'description',
                                 image: image,
                                 published: true}, auth_header_for(user)
      product = Product.first
      expect(response).to have_http_status(:unprocessable_entity)
      expect(product).to be_nil
    end
  end

  describe '/api/v1/products/:id' do
    it 'should remove product' do
      user = create(:user)
      product = create(:product, user_id: user.id)
      expect do
        delete "/api/v1/products/#{product.id}", {}, auth_header_for(user)
      end.to change(Product, :count).by(-1)
    end
  end
end
