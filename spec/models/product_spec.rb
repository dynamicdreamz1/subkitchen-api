require 'rails_helper'

RSpec.describe Product, type: :model do
  let(:product_template){ create(:product_template) }
  let(:product){ create(:product, author: create(:user), product_template: product_template) }
  let(:artist){ create(:user, status: 'verified', artist: true, email_confirmed: true) }
  let(:other_artist){ create(:user, status: 'verified', artist: true, email_confirmed: true) }

  it 'has name' do
    expect(product.name).to_not be_blank
  end

  it 'has user owner' do
    expect(product.author).to be_a User
  end

  describe 'scopes' do
    it 'should return deleted products' do
      product = create(:product)
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

  describe 'publish' do
    let(:user){create(:user, artist: false, status: 'unverified')}
    let(:unverified_artist){create(:user, artist: true, status: 'unverified')}
    let(:verified_artist){create(:user, artist: true, status: 'verified')}

    it 'should publish' do
      product = create(:product, author: verified_artist, published: true)
      expect(product.published).to be_truthy
    end

    it 'should set published at' do
      new_time = Time.local(2008, 9, 1, 12, 0, 0)
      Timecop.freeze(new_time)

      product = create(:product, author: verified_artist, published: true)

      expect(product.published_at).to eq(new_time)
    end

    it 'should raise error when artist false' do
      expect do
        create(:product, author: user, published: true)
      end.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'should raise error when artist unverified' do
      expect do
        create(:product, author: unverified_artist, published: true)
      end.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  describe 'SetProduct on create callback' do
    it 'sets price' do
      expect(product.price).to eq(product_template.price)
    end
  end

  describe 'sort by scope' do
    before do
      @p1 = create(:product, order_items_count: 10, name: 'AAA', created_at: 1.week.ago, product_template: create(:product_template, price: 300, product_type: 'tee'))
      @p2 = create(:product, order_items_count: 20, name: 'CCC', created_at: 2.weeks.ago, product_template: create(:product_template, price: 100, product_type: 'yoga_pants'))
      @p3 = create(:product, order_items_count: 30, name: 'BBB', created_at: 3.weeks.ago, product_template: create(:product_template, price: 200, product_type: 'hoodie'))
    end

    it 'should sort by created_at desc' do
      sorted_products = Product.sorted_by('created_at_desc')

      expect(sorted_products[0]).to eq(@p1)
      expect(sorted_products[1]).to eq(@p2)
      expect(sorted_products[2]).to eq(@p3)
    end

    it 'should sort by created_at asc' do
      sorted_products = Product.sorted_by('created_at_asc')

      expect(sorted_products[0]).to eq(@p3)
      expect(sorted_products[1]).to eq(@p2)
      expect(sorted_products[2]).to eq(@p1)
    end

    it 'should sort by name desc' do
      sorted_products = Product.sorted_by('name_desc')

      expect(sorted_products[0]).to eq(@p2)
      expect(sorted_products[1]).to eq(@p3)
      expect(sorted_products[2]).to eq(@p1)
    end

    it 'should sort by name asc' do
      sorted_products = Product.sorted_by('name_asc')

      expect(sorted_products[0]).to eq(@p1)
      expect(sorted_products[1]).to eq(@p3)
      expect(sorted_products[2]).to eq(@p2)
    end

    it 'should sort by price desc' do
      sorted_products = Product.sorted_by('price_desc')

      expect(sorted_products[0]).to eq(@p1)
      expect(sorted_products[1]).to eq(@p3)
      expect(sorted_products[2]).to eq(@p2)
    end

    it 'should sort by price asc' do
      sorted_products = Product.sorted_by('price_asc')

      expect(sorted_products[0]).to eq(@p2)
      expect(sorted_products[1]).to eq(@p3)
      expect(sorted_products[2]).to eq(@p1)
    end

    it 'should sort by best sellers desc' do
      sorted_products = Product.sorted_by('best_sellers')

      expect(sorted_products[0]).to eq(@p3)
      expect(sorted_products[1]).to eq(@p2)
      expect(sorted_products[2]).to eq(@p1)
    end
  end

  describe 'filters' do
    before do
      @p1 = create(:product, product_template: create(:product_template, price: 300, product_type: 'tee'))
      @p2 = create(:product, product_template: create(:product_template, price: 100, product_type: 'yoga_pants'))
      @p3 = create(:product, product_template: create(:product_template, price: 200, product_type: 'hoodie'))
      @p1.tag_list.add(['cats', 'space'])
      @p1.save
      @p2.tag_list.add(['food'])
      @p2.save
    end
    it 'should filter out products by product type' do
      products = Product.with_product_type('tee')

      expect(products).to contain_exactly(@p1)
    end

    it 'should filter out products by product type' do
      products = Product.with_price_range([0, 150])

      expect(products).to contain_exactly(@p2)
    end

    it 'should filter out products by tag' do
      products = Product.with_tags(['space'])

      expect(products).to contain_exactly(@p1)
    end

    it 'should filter out products by tags' do
      products = Product.with_tags(['space', 'food'])

      expect(products).to contain_exactly(@p1, @p2)
    end
  end
end
