describe Products::Api, type: :request do

  describe '/api/v1/products' do

    context 'sort' do

      before(:each) do
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

      it 'should sort by best sellers' do
        get '/api/v1/products', {sorted_by: 'best_sellers'}

        sorted_products = Product.sorted_by('best_sellers').page(1).per(3)
        serialized_products = ProductListSerializer.new(sorted_products).as_json
        expect(response.body).to eq(serialized_products.to_json)
      end

      it 'should raise error' do
        expect do
          get '/api/v1/products', {sorted_by: 'invalid'}
        end.to raise_error(ArgumentError)
      end
    end
  end
end

