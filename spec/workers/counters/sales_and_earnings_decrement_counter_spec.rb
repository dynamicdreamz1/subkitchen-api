require 'rails_helper'

RSpec.describe 'Earnings Counter' do
  let(:artist) { create(:user, artist: true) }
  let(:user) { create(:user) }
  let(:product) { create(:product, author: artist) }
  let(:order) { create(:order) }
  let(:order2) { create(:order) }

  before(:each) do
    create(:config, name: 'designers', value: '')
    create(:order_item, order: order, product: product, quantity: 3, profit: 5.0)
    @profit = product.product_template.profit * 3
    @payment = create(:payment, payable: order)
  end

  context 'after buying an item' do
    it 'should count weekly earnings' do
			PaypalPayment.new(@payment, Hashie::Mash.new(payment_status: 'Completed')).call
			SalesAndEarningsCounter.drain
			expect do
				order.update(order_status: 6)
				SalesAndEarningsDecrementCounter.drain
			end.to change { artist.earnings_count }.by(-@profit)
    end

    it 'should set weekly percentage' do
      PaypalPayment.new(@payment, Hashie::Mash.new(payment_status: 'Completed')).call
      SalesAndEarningsCounter.drain
			order.update(order_status: 6)
			SalesAndEarningsDecrementCounter.drain
      expect(artist.earnings_weekly).to eq(0)
		end

		it 'should increment sales counter' do
			PaypalPayment.new(@payment, Hashie::Mash.new(payment_status: 'Completed')).call
			SalesAndEarningsCounter.drain
			expect do
				order.update(order_status: 6)
				SalesAndEarningsDecrementCounter.drain
			end.to change { artist.sales_count }.by(-3)
		end

		it 'should set weekly percentage' do
			PaypalPayment.new(@payment, Hashie::Mash.new(payment_status: 'Completed')).call
			SalesAndEarningsCounter.drain
			order.update(order_status: 6)
			SalesAndEarningsDecrementCounter.drain
			expect(artist.sales_weekly).to eq(0)
		end
  end
end
