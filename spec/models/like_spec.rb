RSpec.describe Like, type: :model do
  let(:artist) { create(:user, artist: true, status: 'verified') }
  let(:user) { create(:user, artist: false) }
  let(:product) { create(:product, author: user) }

  it 'should create like' do
    expect do
      create(:like, likeable: create(:product), user: artist)
    end.to change(Like, :count).by(1)
  end

  it 'should raise error when product author and user are same' do
    expect do
      create(:like, likeable: create(:product, author: artist), user: artist)
    end.to raise_error(ActiveRecord::RecordInvalid)
  end

  it 'should raise error when product already liked' do
    expect do
      2.times { create(:like, likeable: product, user: artist) }
    end.to raise_error(ActiveRecord::RecordInvalid)
  end

  it 'should have attributes' do
    like = Like.create
    expect(like.errors[:likeable_type].present?).to eq(true)
    expect(like.errors[:likeable_id].present?).to eq(true)
  end
end
