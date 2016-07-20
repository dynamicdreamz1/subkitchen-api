class PaypalPayment
  def call
		CommonPayment.new(payment, token).call
	end

  private

  attr_accessor :payment, :order
  attr_reader :token

  def initialize(payment, params)
    @payment = payment
    @token = params.txn_id
    @order = payment.payable
  end
end
