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
          PaypalPayment.new(payment, params).call
        else
          MalformedPaymentNotifier.notify(AdminUser.pluck(:email), payment_id: payment.id).deliver_later
          payment.update(payment_status: 3)
					payment.payable.update(order_status: 5)
        end
      else
        DenyPayment.new(payment).call
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
          MalformedPaymentNotifier.notify(AdminUser.pluck(:email), payment_id: payment.id).deliver_later
          payment.update(payment_status: 'malformed')
        end
      else
        DenyUserVerification.new(payment, params).call
      end
    end
  end
end
