RSpec.describe Product, type: :model do
  let(:product_template) { create(:product_template) }
  let(:product) { create(:product, author: create(:user)) }

  it 'has name' do
    expect(product.name).to_not be_blank
  end

  it 'has user owner' do
    expect(product.author).to be_a User
  end

  describe 'SalesCount on save callback' do
    it 'should increment sales count' do
      product = create(:product)
      order = create(:order, order_items: [create(:order_item, product: product, quantity: 2)])
      order.reload
      order.update(purchased: true)
      product.reload
      expect(product.sales_count).to eq(2)
    end
  end

  describe 'SetProduct on create callback' do
    it 'should set price' do
      expect(product.price).to eq(product_template.price)
    end
  end

  it 'should destroy dependent' do
    product_wish_id = create(:product_wish, wished_product: product).id
    product.destroy

    expect { ProductWish.find(product_wish_id) }.to raise_error(ActiveRecord::RecordNotFound)
  end

  it 'should have attributes' do
    product = Product.new
    product.save

    expect(product.errors[:image].present?).to eq(true)
    expect(product.errors[:name].present?).to eq(true)
    expect(product.errors[:description].present?).to eq(true)
    expect(product.errors[:product_template_id].present?).to eq(true)
  end
end
