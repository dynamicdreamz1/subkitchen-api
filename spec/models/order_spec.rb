require 'rails_helper'

RSpec.describe Order, type: :model do
  before do
    create(:config, name: 'tax', value: '6.0')
    create(:config, name: 'shipping_cost', value: '7.0')
    create(:config, name: 'shipping_info', value: 'info')
    @order = create(:order)
    @user = create(:user)
  end

  it 'has state' do
    expect(@order.state).to eq('active')
  end

  it 'has user owner' do
    expect(@order.user).to be_a User
  end
end
