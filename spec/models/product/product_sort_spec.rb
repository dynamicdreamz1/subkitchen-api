RSpec.describe Product, type: :model do
  describe 'sort by scope' do
    before(:each) do
      @p1 = create(:product, order_items_count: 10, name: 'AAA', created_at: 1.week.ago,
                   product_template: create(:product_template, price: 300, product_type: 'tee'))
      @p2 = create(:product, order_items_count: 20, name: 'CCC', created_at: 2.weeks.ago,
                   product_template: create(:product_template, price: 100, product_type: 'yoga_pants'))
      @p3 = create(:product, order_items_count: 30, name: 'BBB', created_at: 3.weeks.ago,
                   product_template: create(:product_template, price: 200, product_type: 'hoodie'))
    end

    it 'should sort by created_at desc' do
      sorted_products = Product.sort_by('created_at_desc')

      expect(sorted_products[0]).to eq(@p1)
      expect(sorted_products[1]).to eq(@p2)
      expect(sorted_products[2]).to eq(@p3)
    end

    it 'should sort by created_at asc' do
      sorted_products = Product.sort_by('created_at_asc')

      expect(sorted_products[0]).to eq(@p3)
      expect(sorted_products[1]).to eq(@p2)
      expect(sorted_products[2]).to eq(@p1)
    end

    it 'should sort by name desc' do
      sorted_products = Product.sort_by('name_desc')

      expect(sorted_products[0]).to eq(@p2)
      expect(sorted_products[1]).to eq(@p3)
      expect(sorted_products[2]).to eq(@p1)
    end

    it 'should sort by name asc' do
      sorted_products = Product.sort_by('name_asc')

      expect(sorted_products[0]).to eq(@p1)
      expect(sorted_products[1]).to eq(@p3)
      expect(sorted_products[2]).to eq(@p2)
    end

    it 'should sort by price desc' do
      sorted_products = Product.sort_by('price_desc')

      expect(sorted_products[0]).to eq(@p1)
      expect(sorted_products[1]).to eq(@p3)
      expect(sorted_products[2]).to eq(@p2)
    end

    it 'should sort by price asc' do
      sorted_products = Product.sort_by('price_asc')

      expect(sorted_products[0]).to eq(@p2)
      expect(sorted_products[1]).to eq(@p3)
      expect(sorted_products[2]).to eq(@p1)
    end

    it 'should sort by best sellers desc' do
      sorted_products = Product.sort_by('best_sellers')

      expect(sorted_products[0]).to eq(@p3)
      expect(sorted_products[1]).to eq(@p2)
      expect(sorted_products[2]).to eq(@p1)
    end
  end
end
