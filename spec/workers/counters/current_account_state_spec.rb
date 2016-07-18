require 'rails_helper'

RSpec.describe 'Current Account State' do
  let(:artist) { create(:user, :artist) }
  let(:product) { create(:product, author: artist) }
  let(:order) { create(:order) }

  before(:each) do
    create(:config, name: 'designers', value: '')
    item = create(:order_item, order: order, product: product, quantity: 3)
		PaypalPayment.new(create(:payment, payable: order),
											Hashie::Mash.new(payment_status: 'Completed')).call
		SalesAndEarningsCounter.drain
		@earning = item.quantity*item.profit
  end

  context 'after creating payout' do
    it 'should recalculate current account state' do
			expect do
				Payout.create(user: artist, value: @earning)
			end.to change{ artist.current_account_state }.by(-@earning)
    end
  end
end
