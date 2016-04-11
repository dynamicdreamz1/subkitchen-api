RSpec.describe Comment, type: :model do
  let(:product1){ create(:product) }
  let(:product2){ create(:product) }
  let(:user){ create(:user, artist: false) }

  it 'should return comments by given product' do
    p1 = create(:comment, product: product1, user: user)
    p2 = create(:comment, product: product2, user: user)

    expect(Comment.product(product1.id)).to contain_exactly(p1)
  end
end
