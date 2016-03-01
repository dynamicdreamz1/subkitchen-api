class ConfirmPayment
  def call
    update_order
  end

  private

  attr_accessor :payment, :params

  def initialize(payment, params)
    @payment = payment
    @params = params
  end

  def update_order
    payment.update_attributes(status: params.payment_status)
    payment.payable.update_arrtibutes(purchased_at: DateTime.now, state: 'inactive')
    payment
  end
end