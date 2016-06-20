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
  end
end
