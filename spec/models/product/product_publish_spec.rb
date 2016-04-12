RSpec.describe Product, type: :model do
  let(:product_template){ create(:product_template) }
  let(:product){ create(:product, author: create(:user), product_template: product_template) }
  let(:artist){ create(:user, status: 'verified', artist: true, email_confirmed: true) }
  let(:other_artist){ create(:user, status: 'verified', artist: true, email_confirmed: true) }

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
end