RSpec.describe Product, type: :model do
  let(:product_template){ create(:product_template) }
  let(:product){ create(:product, author: create(:user), product_template: product_template) }
  let(:artist){ create(:user, status: 'verified', artist: true, email_confirmed: true) }
  let(:other_artist){ create(:user, status: 'verified', artist: true, email_confirmed: true) }

  describe 'scopes' do

    it 'should return deleted products' do
      DeleteProduct.new(product).call
      expect(Product.deleted).to contain_exactly(product)
    end

    it 'should return ready to print products' do
      product = create(:product, design_id: nil)
      ready_product = create(:product, design_id: '123')

      expect(Product.ready_to_print).to contain_exactly(ready_product)
    end

    it 'should return waiting products' do
      product = create(:product, design_id: '123')
      waiting_product = create(:product, design_id: nil)
      order = create(:order, order_status: 'processing')
      create(:order_item, product: product, order: order)
      create(:order_item, product: waiting_product, order: order)

      expect(Product.waiting).to contain_exactly(waiting_product)
    end

    it 'should return all published products' do
      product = create(:product, design_id: nil)
      published_product = create(:product, author: artist, published: true)

      expect(Product.published_all).to contain_exactly(published_product)
    end

    it 'should return all published products by given artist' do
      product = create(:product, design_id: nil)
      create(:product, author: other_artist, published: true)
      published_product = create(:product, author: artist, published: true)

      expect(Product.published(artist)).to contain_exactly(published_product)
    end

    it 'should return all published weekly products by given artist' do
      Timecop.freeze(DateTime.now - 30.days) { create(:product, author: artist, published: true) }
      new_product = create(:product, author: artist, published: true)

      expect(Product.published_weekly(artist)).to contain_exactly(new_product)
    end
  end
end
