describe Products::Api, type: :request do
  describe '/api/v1/products' do
    it 'returns first page of products' do
      create(:product)
      get '/api/v1/products'
      expect(response).to have_http_status(:success)
      expect(response.body).to eq(Product.page(1).to_json)
    end

    it 'paginates' do
      create(:product)
      create(:product)
      get '/api/v1/products?page=1&per_page=1'
      expect(response.body).to eq(Product.page(1).per(1).to_json)
      get '/api/v1/products?page=2&per_page=1'
      expect(response.body).to eq(Product.page(2).per(1).to_json)
    end
  end

  describe '/api/v1/products/:id' do
    it 'returns product' do
      product = create(:product)
      get "/api/v1/products/#{product.id}"
      expect(response.body).to eq(product.to_json)
    end
  end
end
