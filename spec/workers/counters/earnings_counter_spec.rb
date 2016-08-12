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
		CalculateOrder.new(order).call
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

		context 'with coupon' do
			describe 'percentage discount' do
				before(:each) do
					order.update(coupon: create(:coupon, :percentage))
					profit = product.product_template.profit * 3
					@profit_after_discount = profit - profit * 0.2
				end

				it 'should increment artist profit with discount' do
					expect do
						PaypalPayment.new(@payment, Hashie::Mash.new(payment_status: 'Completed')).call
						SalesAndEarningsCounter.drain
					end.to change { artist.earnings_count }.by(@profit_after_discount)
				end
			end

			describe 'value discount' do
				before(:each) do
					discount = 20
					order.update(coupon: create(:coupon, discount: discount))
					discount_percentage = (100 * discount) / order.subtotal_cost
					profit_base = product.product_template.profit
					profit =   (profit_base - profit_base * discount_percentage * 0.01).round(2)
					@profit_after_discount = profit * 3
				end

				it 'should increment artist profit with discount' do
					expect do
						PaypalPayment.new(@payment, Hashie::Mash.new(payment_status: 'Completed')).call
						SalesAndEarningsCounter.drain
					end.to change { artist.earnings_count }.by(@profit_after_discount)
				end
			end
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
