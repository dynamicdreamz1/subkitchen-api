RSpec.describe Product, type: :model do
  let(:product) { create(:product, author: create(:user)) }
  let(:artist) { create(:user, status: 'verified', artist: true) }
  let(:other_artist) { create(:user, status: 'verified', artist: true) }

  describe 'filters' do
    before(:each) do
      @p1 = create(:product, author: artist , product_template: create(:product_template, price: 300, product_type: 'tee'))
      @p2 = create(:product, product_template: create(:product_template, price: 100, product_type: 'yoga_pants'))
      @p3 = create(:product, product_template: create(:product_template, price: 200, product_type: 'hoodie'))
      @p1.tag_list.add(%w(cats space))
      @p1.save
      @p2.tag_list.add(['food'])
      @p2.save
    end
    it 'should filter out products by product type' do
      products = Product.with_product_type('tee')

      expect(products).to contain_exactly(@p1)
    end

    it 'should filter out products by product type' do
      products = Product.with_price_range(0...150)

      expect(products).to contain_exactly(@p2)
    end

    it 'should filter out products by tag' do
      products = Product.with_tags(['space'])

      expect(products).to contain_exactly(@p1)
    end

    it 'should filter out products by tags' do
      products = Product.with_tags(%w(space food))

      expect(products).to contain_exactly(@p1, @p2)
    end

    it 'should filter out products by author' do
      products = Product.with_author(artist.id)

      expect(products).to contain_exactly(@p1)
    end
  end
end
