describe Coupons::Api, type: :request do
  let(:order) { create(:order_with_items_and_coupon) }

  describe '/api/v1/coupon' do
    it 'should remove coupon from order' do
      delete '/api/v1/coupon', order_uuid: order.uuid

			order.reload
      expect(order.coupon).to eq(nil)
      expect(response).to have_http_status(:success)
		end

		it 'should recalculate' do
			discount = order.discount
			subtotal = order.subtotal_cost + discount
			tax = subtotal * order.tax.to_d * 0.01
			total = subtotal + order.shipping_cost.to_d + tax

			delete '/api/v1/coupon', order_uuid: order.uuid

			order.reload
			expect(order.discount).to eq(0)
			expect(order.tax_cost).to eq(tax.round(2))
			expect(order.subtotal_cost).to eq(subtotal.round(2))
			expect(order.total_cost).to eq(total.round(2))
		end

		it 'should return order' do
			delete '/api/v1/coupon', order_uuid: order.uuid

			expect(response).to match_response_schema('order')
		end
  end
end
