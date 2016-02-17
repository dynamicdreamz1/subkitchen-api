require 'rails_helper'

RSpec.describe Product, type: :model do
  before do
    @product = create(:product)
  end

  it 'has name' do
    expect(@product.name).to_not be_blank
  end

  it 'has user owner' do
    expect(@product.user).to be_a User
  end
end
