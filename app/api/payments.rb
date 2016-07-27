module Payments
  class Api < Grape::API
    resources :orders do
      desc 'payment page'
      get ':uuid/payment' do
        order = Order.find_by!(uuid: params.uuid, purchased: false)
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

        requires :payment_type, type: String, values: %w(stripe paypal)
        optional :stripe_token, type: String
        optional :return_path, type: String
      end
      post ':uuid/payment' do
        order = Order.find_by!(uuid: params.uuid, active: true, order_status: 'creating')
        error!({ errors: { base: ['invalid payment parameters!'] } }, 422) unless ValidPaymentParams.new(params).call

        unless AddOrderAddress.new(params, order).call
          status :unprocessable_entity
          return CheckoutSerializer.new(order).as_json
        end

        unless AddOrderAddress.new(params, order).call && CheckOrderItems.new(order).call
          status :unprocessable_entity
          return UpdateOrderItems.new(order).call
        end

        OrderConfirmationMailer.notify(order.email, order: order).deliver_later

        CreatePayment.new(order, params.payment_type, params.stripe_token, params.return_path).call ||
          error!({ errors: { base: ['already paid'] } }, 422)
      end
    end
  end
end
