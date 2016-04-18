RSpec.describe Product, type: :model do
  let(:user) { create(:user, artist: false, status: 'unverified') }
  let(:unverified_artist) { create(:user, artist: true, status: 'unverified') }

  describe 'publish' do
    it 'should publish' do
      product = create(:product, :published)
      expect(product.published).to be_truthy
    end

    it 'should set published at' do
      new_time = Time.local(2008, 9, 1, 12, 0, 0)
      Timecop.freeze(new_time)

      product = create(:product, :published)

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
