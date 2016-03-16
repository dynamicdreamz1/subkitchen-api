module Payments
  class Api < Grape::API

    resources :orders do

      desc 'payment page'
      get ':uuid/payment' do
        order = Order.find_by!(uuid: params.uuid)
        if CheckOrderItems.new(order).call
          CheckoutSerializer.new(order).as_json
        else
          UpdateOrderItems.new(order).call
        end
      end

      desc 'create stripe or paypal payment'
      params do
        requires :email, type: String
        requires :full_name, type: String
        requires :address, type: String
        requires :city, type: String
        requires :zip, type: String
        requires :region, type: String
        requires :country, type: String

        requires :payment_type, type: String, values: ['stripe', 'paypal']
        optional :stripe_token, type: String
        optional :return_path, type: String
      end
      post ':uuid/payment' do
        order = Order.find_by!(uuid: params.uuid)
        AddOrderAddress.new(params, order).call
        unless CheckOrderItems.new(order).call
          UpdateOrderItems.new(order).call
          error!({errors: {base: ['some of the items had to be removed because the products does not exist anymore']}}, 422)
        end
        CreatePayment.new(order, params.payment_type, params.stripe_token, params.return_path).call || error!({errors: {base: ['already paid']}}, 422)
      end
    end
  end
end
