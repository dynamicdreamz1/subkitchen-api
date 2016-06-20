module Coupons
  class Api < Grape::API
    desc 'Validates coupon and recalculates order with discount'
    params do
      requires :order_uuid, type: String
      requires :coupon_code, type: String
    end
    post 'coupon' do
      order = Order.find_by!(uuid: params.order_uuid)
      ApplyCoupon.new(order, params.coupon_code).call
      OrderSerializer.new(order).as_json
		end

		desc 'Removes coupon from order'
		params do
			requires :order_uuid, type: String
		end
		delete 'coupon' do
			order = Order.find_by!(uuid: params.order_uuid)
			RemoveCoupon.new(order).call
			OrderSerializer.new(order).as_json
		end
  end
end
