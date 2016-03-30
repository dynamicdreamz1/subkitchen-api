describe Products::Api, type: :request do
  let(:product_template){ create(:product_template) }
  let(:artist){ create(:user, artist: true) }
  let(:user){ create(:user, artist: false) }

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

        it 'should sort by best sellers param' do
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

      context 'filter' do

        before(:each) do
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
  end
end
