module PaypalHooks
  class Api < Grape::API
    params do
      requires :txn_id, type: String
      requires :invoice, type: Integer
      requires :payment_status, type: String
    end
    post 'payment_notification' do
      payment = Payment.find(params.invoice)
      if params.payment_status == 'Completed'
        if CheckForFraud.new(params, payment).call
          ConfirmPayment.new(payment, params).call
        else
          #send email
          error!({errors: {base: ['cannot confirm payment!']}}, 422)
        end
      else
        DenyPaypalPayment.new(payment, params).call
      end
    end

    params do
      requires :txn_id, type: String
      requires :invoice, type: Integer
      requires :payment_status, type: String
    end
    post 'user_verify_notification' do
      payment = Payment.find(params.invoice)
      if params.payment_status == 'Completed'
        if CheckForFraud.new(params, payment).call
          ConfirmUserVerification.new(payment, params).call
        else
          #send email
          error!({errors: {base: ['cannot confirm payment!']}}, 422)
        end
      else
        DenyUserVerification.new(payment, params).call
      end
    end
  end
end
