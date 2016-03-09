module Payments
  class Api < Grape::API

    resources :orders do

      desc 'create stripe or paypal payment'
      params do
        requires :payment_type, type: String, values: ['stripe', 'paypal']
        optional :stripe_token, type: String
        optional :return_path, type: String
      end
      post ':uuid/payment' do
        order = Order.find_by(uuid: params.uuid)
        error!({errors: {base: ['cannot find order']}}, 422) if order.nil?
        unless CheckOrderItems.new(order).call
          UpdateOrderItems.new(order).call
          error!({errors: {base: ['some of the items had to be removed because the products does not exist anymore']}}, 422)
        end
        CreatePayment.new(order, params.payment_type, params.stripe_token, params.return_path).call || error!({errors: {base: ['already paid']}}, 422)
      end
    end
  end
end