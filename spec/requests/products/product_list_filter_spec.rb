describe Products::Api, type: :request do
  describe '/api/v1/products' do
    context 'filter' do
      before(:each) do
        @user = create(:user)
        @p1 = create(:product, author_id: @user.id, name: 'AAA', created_at: 1.week.ago, product_template: create(:product_template, price: 100, product_type: 'tee'))
        @p2 = create(:product, name: 'BBB', created_at: 2.weeks.ago, product_template: create(:product_template, price: 200, product_type: 'hoodie'))
        @p3 = create(:product, name: 'CCC', created_at: 3.weeks.ago, product_template: create(:product_template, price: 300, product_type: 'yoga_pants'))
        @p1.tag_list.add(%w(cats space))
        @p1.save
        @p3.tag_list.add(['music'])
        @p3.save
      end

      it 'should filter products with product type' do
        get '/api/v1/products', with_product_type: ['tee']

        products = Product.sorted_by('created_at_desc').where(id: @p1.id)
        products = products.page(1).per(3)
        serialized_products = ProductListSerializer.new(products).as_json

        expect(response.body).to eq(serialized_products.to_json)
      end

      it 'should filter products with multiple product types' do
        get '/api/v1/products', with_product_type: %w(tee hoodie yoga_pants)

        products = Product.sorted_by('created_at_desc').where(id: [@p1.id, @p2.id, @p3.id])
        products = products.page(1).per(3)
        serialized_products = ProductListSerializer.new(products).as_json

        expect(response.body).to eq(serialized_products.to_json)
      end

      it 'should filter products with price range' do
        get '/api/v1/products', with_price_range: [0, 101]

        products = Product.sorted_by('created_at_desc').where(id: [@p1.id])
        products = products.page(1).per(3)
        serialized_products = ProductListSerializer.new(products).as_json

        expect(response.body).to eq(serialized_products.to_json)
      end

      it 'should filter products with tags' do
        get '/api/v1/products', with_tags: %w(cats music)

        products = Product.sorted_by('created_at_desc').where(id: [@p1.id, @p3.id])
        products = products.page(1).per(3)
        serialized_products = ProductListSerializer.new(products).as_json

        expect(response.body).to eq(serialized_products.to_json)
      end

      it 'should filter products with author' do
        get '/api/v1/products', author_id: @user.id

        products = Product.where(id: @p1.id)
        products = products.page(1).per(3)
        serialized_products = ProductListSerializer.new(products).as_json

        expect(response.body).to eq(serialized_products.to_json)
      end
    end
  end
end
