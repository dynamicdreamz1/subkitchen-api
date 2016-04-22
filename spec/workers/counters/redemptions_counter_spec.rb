RSpec.describe 'Earnings Counter' do
  let(:stripe_helper) { StripeMock.create_test_helper }
  before { StripeMock.start }
  after { StripeMock.stop }

  let(:coupon){ create(:coupon, :one_time_limit) }
  let(:order){ create(:order_with_items, coupon: coupon) }
  let(:payment){ create(:payment, payable: order) }


  before(:each) do
    create(:config, name: 'designers', value: '')
  end

  it 'should increment after paypal payment' do
    CreatePayment.new(order, 'paypal', nil, '').call
    RedemptionsCounter.drain

    expect(coupon.redemptions_count).to eq(1)
  end

  it 'should increment after stripe payment' do
    CreatePayment.new(order, 'stripe', stripe_helper.generate_card_token, nil).call
    RedemptionsCounter.drain

    expect(coupon.redemptions_count).to eq(1)
  end
end
