describe Coupons::Api, type: :request do
  let(:order){ create(:order_with_items) }

  describe '/api/v1/coupon' do
    it 'should return error when code invalid' do
      post '/api/v1/coupon', { order_uuid: order.uuid, coupon_code: '123456' }

      expect(json['errors']).to eq('base' => ['record not found'])
      expect(response).to have_http_status(:not_found)
    end

    it 'should return error when coupon expired' do
      Timecop.freeze(DateTime.now - 10.days) do
        coupon = create(:coupon, valid_from: DateTime.now, valid_until: DateTime.now + 1.day)

        Timecop.freeze(DateTime.now + 2.days) do
          post '/api/v1/coupon', { order_uuid: order.uuid, coupon_code: coupon.code }

          expect(json['errors']).to eq('base' => ['Coupon invalid or expired'])
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end

    it 'should return error when counter exceeds limit' do
      coupon = create(:coupon, :one_time_limit)
      $redis.incr("coupon_#{coupon.id}_redemptions_counter")

      post '/api/v1/coupon', { order_uuid: order.uuid, coupon_code: coupon.code }

      expect(json['errors']).to eq('base' => ['Coupon invalid or expired'])
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'should return order' do
      coupon = create(:coupon)

      post '/api/v1/coupon', { order_uuid: order.uuid, coupon_code: coupon.code }

      expect(response).to match_response_schema('order')
    end

    it 'calculate discount' do
      coupon = create(:coupon)

      post '/api/v1/coupon', { order_uuid: order.uuid, coupon_code: coupon.code }

      order.reload
      expect(response).to have_http_status(:success)
      expect(order.coupon).to eq(coupon)
      expect(order.discount).to eq(coupon.discount)
    end

    it 'recalculate order' do
      coupon = create(:coupon)
      subtotal = order.subtotal_cost

      post '/api/v1/coupon', { order_uuid: order.uuid, coupon_code: coupon.code }

      order.reload
      new_subtotal = (subtotal - coupon.discount).round(2)
      new_tax = (new_subtotal * order.tax.to_d * 0.01).round(2)
      new_total = (new_subtotal + new_tax + order.shipping_cost.to_d).round(2)

      expect(order.subtotal_cost).to eq(new_subtotal)
      expect(order.total_cost).to eq(new_total)
      expect(order.tax_cost).to eq(new_tax)
    end

    it 'recalculate order when discount is percentage' do
      coupon = create(:coupon, :percentage)
      subtotal = order.subtotal_cost
      discount = coupon.discount * 0.01 * order.subtotal_cost

      post '/api/v1/coupon', { order_uuid: order.uuid, coupon_code: coupon.code }

      order.reload

      new_subtotal = (subtotal - discount).round(2)
      new_tax = (new_subtotal * order.tax.to_d * 0.01).round(2)
      new_total = (new_subtotal + new_tax + order.shipping_cost.to_d).round(2)

      expect(order.discount).to eq(discount)

      expect(order.subtotal_cost).to eq(new_subtotal)
      expect(order.total_cost).to eq(new_total)
      expect(order.tax_cost).to eq(new_tax)
    end

    it 'calculate discount when discount is percentage' do
      coupon = create(:coupon, :percentage)
      discount = coupon.discount * 0.01 * order.subtotal_cost

      post '/api/v1/coupon', { order_uuid: order.uuid, coupon_code: coupon.code }

      order.reload

      expect(response).to have_http_status(:success)
      expect(order.coupon).to eq(coupon)
      expect(order.discount).to eq(discount)
    end
  end
end
