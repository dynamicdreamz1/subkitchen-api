require 'rails_helper'

RSpec.describe Product, type: :model do
  before do
    user = create(:user)
    @product = create(:product, author: user)
  end

  it 'has name' do
    expect(@product.name).to_not be_blank
  end

  it 'has user owner' do
    expect(@product.author).to be_a User
  end
end
