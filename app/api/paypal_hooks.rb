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
          NotifyDesigners.new(payment.payable).call
          ConfirmPayment.new(payment, params).call
        else
          AdminNotifier.send_malformed_payment_email(payment)
          payment.update(payment_status: 'malformed')
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
          AdminNotifier.send_malformed_payment_email(payment)
          payment.update(payment_status: 'malformed')
        end
      else
        DenyUserVerification.new(payment, params).call
      end
    end
  end
end
