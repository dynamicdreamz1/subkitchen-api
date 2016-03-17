class CheckForFraud
  def call
    check_for_fraud
  end

  private

  attr_reader :params, :order

  def initialize(params, payment)
    @params = params
    @order = payment.payable
  end

  def check_for_fraud
    params.payment_gross.to_d == order.total_cost && params.receiver_email == Figaro.env.paypal_seller
  end
end