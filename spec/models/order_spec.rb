require 'rails_helper'

RSpec.describe Order, type: :model do
  before do
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
