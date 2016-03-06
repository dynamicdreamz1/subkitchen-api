require 'rails_helper'

RSpec.describe Product, type: :model do
  let(:product_template){ create(:product_template) }
  let(:product){ create(:product, author: create(:user), product_template: product_template) }

  it 'has name' do
    expect(product.name).to_not be_blank
  end

  it 'has user owner' do
    expect(product.author).to be_a User
  end

  it 'sets price' do
    expect(product.price).to eq(product_template.price)
  end

  it 'updates price' do
    product_template.update(price: 100)
    expect(product.price).to eq(100)
  end

  context 'sort by scope' do
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

  context 'filters' do

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
