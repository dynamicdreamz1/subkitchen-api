RSpec.describe Product, type: :model do
  let(:product) { create(:product, author: create(:user), product_template: create(:product_template)) }
  let(:artist) { create(:user, status: 'verified', artist: true) }
  let(:other_artist) { create(:user, status: 'verified', artist: true) }

  describe 'scopes' do
    context 'deleted products' do
      before(:each) do
        DeleteProduct.new(product).call
      end

      it 'should return deleted products' do
        expect(Product.deleted).to contain_exactly(product)
      end
    end

    context 'ready to print' do
      before(:each) do
        product = create(:product, design_id: nil)
        @ready_product = create(:product, design_id: '123')
      end

      it 'should return ready to print products' do
        expect(Product.ready_to_print).to contain_exactly(@ready_product)
      end
    end

    context 'waiting products' do
      before(:each) do
        product = create(:product, design_id: '123')
        @waiting_product = create(:product, design_id: nil)
        order = create(:order, order_status: 'processing')
        create(:order_item, product: product, order: order)
        create(:order_item, product: @waiting_product, order: order)
      end

      it 'should return waiting products' do
        expect(Product.waiting).to contain_exactly(@waiting_product)
      end
    end

    context 'published products' do
      before(:each) do
        product = create(:product, design_id: nil)
        @published_product = create(:product, author: artist, published: true)
      end

      it 'should return all published products' do
        expect(Product.published_all).to contain_exactly(@published_product)
      end
    end

    context 'published by given artist' do
      before(:each) do
        product = create(:product, design_id: nil)
        create(:product, author: other_artist, published: true)
        @published_product = create(:product, author: artist, published: true)
      end

      it 'should return all published products by given artist' do
        expect(Product.published(artist)).to contain_exactly(@published_product)
      end
    end

    context 'published weekly by given artist' do
      before(:each) do
        Timecop.freeze(DateTime.now - 30.days) { create(:product, author: artist, published: true) }
        @new_product = create(:product, author: artist, published: true)
      end

      it 'should return all published weekly products by given artist' do
        expect(Product.published_weekly(artist)).to contain_exactly(@new_product)
      end
    end
  end
end
