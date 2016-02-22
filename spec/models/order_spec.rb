require 'rails_helper'

RSpec.describe Order, type: :model do
  before do
    @order = create(:order)
    @user = create(:user)
  end

  it 'has state' do
    expect(@order.state).to eq('active')
  end

  it 'has order_type' do
    expect(@order.order_type).to eq('cart')
  end

  it 'has user owner' do
    expect(@order.user).to be_a User
  end

  it 'should raise error' do
    create(:order, user: @user, order_type: 'cart', state: 'active')
    expect{create(:order, user: @user, order_type: 'cart', state: 'active')}.to raise_error{ ActiveRecord::RecordInvalid }
  end

  it 'should not raise error' do
    create(:order, user: @user, order_type: 'cart', state: 'inactive')
    create(:order, user: @user, order_type: 'verification', state: 'active')
    expect{create(:order, user: @user, order_type: 'cart', state: 'active')}.not_to raise_error{ ActiveRecord::RecordInvalid }
  end
end
