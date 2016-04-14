RSpec.describe Comment, type: :model do
  let(:user) { create(:user, artist: false) }

  before(:each) do
    @product1 = create(:product)
    product2 = create(:product)
    @p1 = create(:comment, product: @product1, user: user)
    p2 = create(:comment, product: product2, user: user)
  end

  it 'should return comments by given product' do
    expect(Comment.product(@product1.id)).to contain_exactly(@p1)
  end
end
