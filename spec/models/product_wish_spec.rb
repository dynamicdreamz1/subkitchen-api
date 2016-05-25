RSpec.describe ProductWish, type: :model do
  before(:each) do
    @user = create(:user)
    @product = create(:product)
    create(:product_wish, user: @user, wished_product: @product)
  end

  it 'should create' do
    expect(@user.wished_products.count).to eq(1)
  end

  it 'should not create duplicate' do
    expect do
      create(:product_wish, user: @user, wished_product: @product)
    end.to raise_error(ActiveRecord::RecordInvalid)
  end

  it 'should have attributes' do
    wish = ProductWish.create

    expect(wish.errors[:wished_product_id].present?).to eq(true)
    expect(wish.errors[:user_id].present?).to eq(true)
  end
end
