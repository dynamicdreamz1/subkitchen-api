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
      expect do
        PaypalPayment.new(@payment, Hashie::Mash.new(payment_status: 'Completed')).call
        SalesAndEarningsCounter.drain
      end.to change { artist.earnings_count }.by(@profit)
    end

    it 'should set weekly percentage' do
      PaypalPayment.new(@payment, Hashie::Mash.new(payment_status: 'Completed')).call
      SalesAndEarningsCounter.drain

      expect(artist.earnings_weekly).to eq(100)
    end

    context 'with earnings older than one week' do
      before(:each) do
        Timecop.freeze(DateTime.now - 30.days) do
          create(:order_item, order: order2, product: product, quantity: 3, profit: 5.0)
          payment2 = create(:payment, payable: order2)
          PaypalPayment.new(payment2, Hashie::Mash.new(payment_status: 'Completed')).call
          SalesAndEarningsCounter.drain
        end
      end

      it 'should count weekly earnings' do
        expect do
          PaypalPayment.new(@payment, Hashie::Mash.new(payment_status: 'Completed')).call
          SalesAndEarningsCounter.drain
        end.to change { artist.earnings_count }.by(@profit)
      end

      it 'should set weekly percentage' do
        PaypalPayment.new(@payment, Hashie::Mash.new(payment_status: 'Completed')).call
        SalesAndEarningsCounter.drain

        expect(artist.earnings_weekly).to eq(50)
      end
    end
  end
end
