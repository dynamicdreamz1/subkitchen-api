module PaypalHooks
  class Api < Grape::API
    params do
      requires :invoice, type: Integer
      requires :payment_status, type: String
    end
    post 'payment_notification' do
      payment = Payment.find_by(id: params.invoice)
      if params.payment_status == 'Completed'
        ConfirmPayment.new(payment, params).call
      end
    end

    params do
      requires :invoice, type: Integer
      requires :payment_status, type: String
    end
    post 'user_verify_notification' do
      payment = Payment.find_by(id: params.invoice)
      if params.payment_status == 'Completed'
        ConfirmUserVerification.new(payment, params).call
      end
    end
  end
end
