require 'rails_helper'

RSpec.describe 'Sales Counter' do
  let(:artist) { create(:user, artist: true) }
  let(:user) { create(:user) }
  let(:product) { create(:product, author: artist) }
  let(:order) { create(:order) }
  let(:order2) { create(:order) }

  before(:each) do
    create(:order_item, order: order, product: product, quantity: 3, profit: 5.0)
    @profit = product.product_template.profit * 3
    @payment = create(:payment, payable: order)
  end

  context 'after buying item' do
    it 'should increment sales counter' do
      expect do
        ConfirmPayment.new(@payment, Hashie::Mash.new(payment_status: 'Completed')).call
        SalesAndEarningsCounter.drain
      end.to change { artist.sales_count }.by(3)
    end

    it 'should set weekly percentage' do
      ConfirmPayment.new(@payment, Hashie::Mash.new(payment_status: 'Completed')).call
      SalesAndEarningsCounter.drain
      expect(artist.sales_weekly).to eq(100)
    end

    context 'with sales older than one week' do
      before(:each) do
        Timecop.freeze(DateTime.now - 30.days) do
          create(:order_item, order: order2, product: product, quantity: 3, profit: 5.0)
          payment2 = create(:payment, payable: order2)
          ConfirmPayment.new(payment2, Hashie::Mash.new(payment_status: 'Completed')).call
          SalesAndEarningsCounter.drain
        end
      end

      it 'should count only past week sales' do
        expect do
          ConfirmPayment.new(@payment, Hashie::Mash.new(payment_status: 'Completed')).call
          SalesAndEarningsCounter.drain
        end.to change { artist.sales_count }.by(3)
      end

      it 'should set only past week percentage' do
        ConfirmPayment.new(@payment, Hashie::Mash.new(payment_status: 'Completed')).call
        SalesAndEarningsCounter.drain

        expect(artist.sales_weekly).to eq(50)
      end
    end
  end
end
