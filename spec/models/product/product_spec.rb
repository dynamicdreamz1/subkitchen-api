RSpec.describe Product, type: :model do
  let(:product_template) { create(:product_template) }
  let(:product) { create(:product, author: create(:user)) }

  it 'has name' do
    expect(product.name).to_not be_blank
  end

  it 'has user owner' do
    expect(product.author).to be_a User
  end

  describe 'SetProduct on create callback' do
    it 'sets price' do
      expect(product.price).to eq(product_template.price)
    end
  end

  it 'should destroy dependent' do
    product_wish_id = create(:product_wish, wished_product: product).id
    product.destroy

    expect{ ProductWish.find(product_wish_id) }.to raise_error(ActiveRecord::RecordNotFound)
  end
end
