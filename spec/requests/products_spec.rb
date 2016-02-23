describe Products::Api, type: :request do
  describe '/api/v1/products' do
    it 'returns first page of products' do
      create(:product)
      get '/api/v1/products'
      expect(response).to have_http_status(:success)
      expect(json["products"]).to eq(Product.page(1).map{|p| ProductSerializer.serialize(p).stringify_keys})
    end

    it 'paginates' do
      create(:product)
      create(:product)
      get '/api/v1/products', page: 1, per_page: 1
      expect(json["products"]).to eq(Product.page(1).per(1).map{|p| ProductSerializer.serialize(p).stringify_keys})
      get '/api/v1/products', page: 2, per_page: 1
      expect(json["products"]).to eq(Product.page(2).per(1).map{|p| ProductSerializer.serialize(p).stringify_keys})
    end
  end

  describe '/api/v1/products/:id' do
    it 'returns product' do
      user = create(:user)
      product = create(:product, author: user)
      get "/api/v1/products/#{product.id}"
      expect(json["product"]).to eq(ProductSerializer.serialize(product).stringify_keys)
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
                                   image: image }, auth_header_for(user)
      product = Product.first
      expect(response.body).to eq(product.to_json)
      expect(product.image_id).to be_truthy
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
