require 'rails_helper'

RSpec.describe Product, type: :model do
  before do
    user = create(:user)
    @product_template = create(:product_template)
    @product = create(:product, author: user, product_template: @product_template)
  end

  it 'has name' do
    expect(@product.name).to_not be_blank
  end

  it 'has user owner' do
    expect(@product.author).to be_a User
  end

  it 'sets price' do
    price = @product_template.price
    @product_template.price = 100
    @product_template.save
    expect(@product.price).to eq(price)
  end

  it 'should count sales' do

  end
end
