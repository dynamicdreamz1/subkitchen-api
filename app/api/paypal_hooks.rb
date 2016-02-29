module PaypalHooks
  class Api < Grape::API
    params do
      requires :invoice, type: Integer
      requires :payment_status, type: String
      requires :transaction_id, type: Integer
    end
    post 'payment_notification' do
      payment = Payment.find_by(id: params.invoice)
      if params.status == 'Completed'
        ConfirmPayment.new(payment, params).update_order
      end
    end

    params do
      requires :invoice, type: Integer
      requires :payment_status, type: String
      requires :transaction_id, type: Integer
    end
    post 'user_verify_notification' do
      payment = Payment.find_by(id: params.invoice)
      if params.status == 'Completed'
        ConfirmPayment.new(payment, params).update_artist
      end
    end
  end
end
