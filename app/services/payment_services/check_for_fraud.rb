class CheckForFraud
  def call
    check_for_fraud
  end

  private

  attr_reader :params, :payment

  def initialize(params, payment)
    @params = params
    @payment = payment
  end

  def check_for_fraud
    if payment.payable_type == 'Order'
      params.payment_gross.to_d == payment.payable.total_cost && params.receiver_email == Figaro.env.paypal_seller
    else
      params.payment_gross.to_d == 1.00 && params.receiver_email == Figaro.env.paypal_seller
    end
  end
end