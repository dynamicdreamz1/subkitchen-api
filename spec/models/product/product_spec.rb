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

  describe 'SetProduct on create callback' do
    it 'sets price' do
      expect(product.price).to eq(product_template.price)
    end
  end
end